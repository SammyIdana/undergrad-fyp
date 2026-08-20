import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/water_data.dart';

const String apiEndpoint = 'https://water-quality-monitor-api.onrender.com/api/telemetry/latest/ESP32_221A74';
const Duration _httpTimeout = Duration(seconds: 8);
const Duration _pollInterval = Duration(seconds: 10);
final Uri _apiEndpointUri = Uri.parse(apiEndpoint);

final waterDataProvider = StreamProvider<WaterData>((ref) async* {
  bool isAlive = true;
  bool hasYieldedData = false;
  ref.onDispose(() => isAlive = false);

  try {
    while (isAlive) {
      try {
        final response = await http.get(_apiEndpointUri).timeout(_httpTimeout);

        if (response.statusCode == 200) {
          final Map<String, dynamic> rawJson = json.decode(response.body);
          yield WaterData.fromJson(rawJson);
          hasYieldedData = true;
        } else if (response.statusCode == 404) {
          final waitingData = WaterData(
            deviceId: 'ESP32_221A74',
            ph: 0.0,
            tds: 0.0,
            turbidity: 0.0,
            temperature: 0.0,
            status: 'WAITING',
            timestamp: DateTime.now(),
          );
          yield waitingData;
          hasYieldedData = true;
        } else {
          throw Exception('Backend HTTP Status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Polling interval glitch: $e');
        if (!hasYieldedData) {
          yield WaterData(
            deviceId: 'ESP32_221A74',
            ph: 0.0,
            tds: 0.0,
            turbidity: 0.0,
            temperature: 0.0,
            status: 'WAITING',
            timestamp: DateTime.now(),
          );
          hasYieldedData = true;
        }
      }

      // Polls the server every 10 seconds
      await Future.delayed(_pollInterval);
    }
  } catch (globalError) {
    debugPrint('Switching to local testing simulation loop.');
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