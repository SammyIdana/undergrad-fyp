import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/water_data.dart';
import '../services/local_storage_service.dart';

const String apiEndpoint = 'https://water-quality-monitor-api.onrender.com/api/telemetry/latest/ESP32_221A74';
final _localStorageService = LocalStorageService();

final waterDataProvider = StreamProvider<WaterData>((ref) async* {
  bool isAlive = true;
  ref.onDispose(() => isAlive = false);

  try {
    while (isAlive) {
      try {
        final response = await http.get(Uri.parse(apiEndpoint)).timeout(
          const Duration(seconds: 8),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> rawJson = json.decode(response.body);
          final data = WaterData.fromJson(rawJson);
          
          // Cache the data locally
          await _localStorageService.cacheWaterData(data);
          
          yield data;
        } else if (response.statusCode == 404) {
          final data = WaterData(
            deviceId: 'ESP32_221A74',
            ph: 0.0,
            tds: 0.0,
            turbidity: 0.0,
            temperature: 0.0,
            status: 'WAITING',
            timestamp: DateTime.now(),
          );
          await _localStorageService.cacheWaterData(data);
          yield data;
        } else {
          throw Exception('Backend HTTP Status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Polling interval glitch: $e');
        
        // Try to use cached data on error
        final lastCached = await _localStorageService.getLastCachedReading();
        if (lastCached != null) {
          debugPrint('🔄 Using cached data from local storage');
          yield lastCached;
        }
      }

      // Polls the server every 10 seconds
      await Future.delayed(const Duration(seconds: 10));
    }
  } catch (globalError) {
    debugPrint('Switching to cached data or local testing simulation loop.');
    
    // Try to get cached history first
    final cachedHistory = await _localStorageService.getCachedHistoryData();
    if (cachedHistory.isNotEmpty) {
      debugPrint('📦 Loading ${cachedHistory.length} readings from cache');
      for (final data in cachedHistory) {
        if (isAlive) yield data;
      }
    }
    
    // Fallback to simulation if no cache
    yield* Stream.periodic(const Duration(seconds: 3), (count) {
      double ph = 7.0 + (count % 3) * 0.2;
      double tds = 300.0 + (count * 10);
      double temp = 25.0 + (count % 2);
      String status = 'SAFE';
      if (tds > 400) status = 'CAUTION';
      if (tds > 500) status = 'LIMITED USE';
      if (tds > 600) status = 'DANGEROUS';
      
      return WaterData(
        deviceId: 'ESP32_221A74',
        ph: ph,
        tds: tds,
        turbidity: 1.0,
        temperature: temp,
        status: status,
        timestamp: DateTime.now(),
      );
    });
  }
});