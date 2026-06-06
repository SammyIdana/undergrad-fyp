import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/water_data.dart';
import '../services/local_storage_service.dart';
import 'water_data_provider.dart';

const String historyApiEndpoint = 'https://water-quality-monitor-api.onrender.com/api/telemetry/history/ESP32_221A74';
final _localStorageService = LocalStorageService();

class HistoryNotifier extends Notifier<List<WaterData>> {
  @override
  List<WaterData> build() {
    // Initial load from cloud database logs
    fetchHistoricalDatabaseRecords();

    // Dynamically listen to the stream provider to append new logs without needing a reload
    ref.listen<AsyncValue<WaterData>>(
      waterDataProvider,
      (previous, next) {
        if (next.value != null && next.value!.status != 'WAITING') {
          final newEntry = next.value!;
          final containsTimestamp = state.any((element) => element.timestamp == newEntry.timestamp);
          
          if (!containsTimestamp) {
            state = [...state, newEntry];
            // Also cache the new entry
            _localStorageService.cacheWaterData(newEntry);
          }
        }
      },
    );
    return [];
  }

  Future<void> fetchHistoricalDatabaseRecords() async {
    try {
      final response = await http.get(Uri.parse(historyApiEndpoint)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        List<dynamic> targetList = [];

        // 🛡️ DRILL SAFELY INTO THE NESTED DATA WRAPPER Coming from Render
        if (decodedBody['data'] != null && decodedBody['data'] is List) {
          targetList = decodedBody['data'];
        } else if (decodedBody['success'] == true && decodedBody['data'] == null) {
          debugPrint('History loaded successfully but database collection is currently empty.');
          state = [];
          return;
        } else if (decodedBody is List) {
          targetList = decodedBody as List;
        }

        final List<WaterData> fetchedHistory = targetList
            .map((document) => WaterData.fromJson(document as Map<String, dynamic>))
            .toList();

        // Sort chronologically (oldest to newest) so fl_chart plots correctly from left to right
        fetchedHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        state = fetchedHistory;
        // Cache the history for offline access
        await _localStorageService.cacheHistoryData(fetchedHistory);
        debugPrint('✅ Successfully loaded ${state.length} historical data points.');
      } else {
        debugPrint('History tracking error status code: ${response.statusCode}');
        
        // Try to load from cache on error
        final cachedHistory = await _localStorageService.getCachedHistoryData();
        if (cachedHistory.isNotEmpty) {
          state = cachedHistory;
          debugPrint('🔄 Loaded ${state.length} historical points from local cache');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error pulling database historical logs: $e');
      debugPrint('Stacktrace: $stackTrace');
      
      // Try to load from cache on error
      final cachedHistory = await _localStorageService.getCachedHistoryData();
      if (cachedHistory.isNotEmpty) {
        state = cachedHistory;
        debugPrint('🔄 Loaded ${state.length} historical points from local cache');
      }
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<WaterData>>(
  () => HistoryNotifier(),
);