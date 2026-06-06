import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_data.dart';

class LocalStorageService {
  static const String _waterDataCacheKey = 'water_data_cache';
  static const String _cacheTimestampKey = 'water_data_cache_timestamp';
  static const int _maxCachedReadings = 50;
  static const Duration _cacheValidity = Duration(minutes: 5);

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  /// Save water data to local cache
  Future<void> cacheWaterData(WaterData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing cache
      final cachedJson = prefs.getString(_waterDataCacheKey);
      List<dynamic> cachedList = cachedJson != null ? json.decode(cachedJson) : [];

      // Add new data
      final dataJson = {
        'deviceId': data.deviceId,
        'status': data.status,
        'ph': data.ph,
        'tds': data.tds,
        'turbidity': data.turbidity,
        'temperature': data.temperature,
        'timestamp': data.timestamp.toIso8601String(),
      };

      cachedList.add(dataJson);

      // Keep only last 50 readings
      if (cachedList.length > _maxCachedReadings) {
        cachedList = cachedList.sublist(cachedList.length - _maxCachedReadings);
      }

      // Save back
      await prefs.setString(_waterDataCacheKey, json.encode(cachedList));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('✅ Cached water data locally');
    } catch (e) {
      debugPrint('❌ Error caching water data: $e');
    }
  }

  /// Get cached water data readings
  Future<List<WaterData>> getCachedWaterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_waterDataCacheKey);

      if (cachedJson == null) {
        return [];
      }

      final cachedList = json.decode(cachedJson) as List<dynamic>;
      return cachedList
          .map((item) => WaterData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error retrieving cached water data: $e');
      return [];
    }
  }

  /// Get the most recent cached reading
  Future<WaterData?> getLastCachedReading() async {
    try {
      final cached = await getCachedWaterData();
      return cached.isNotEmpty ? cached.last : null;
    } catch (e) {
      debugPrint('❌ Error getting last cached reading: $e');
      return null;
    }
  }

  /// Check if cache is still valid
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      return now.difference(cacheTime) < _cacheValidity;
    } catch (e) {
      debugPrint('❌ Error checking cache validity: $e');
      return false;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_waterDataCacheKey);
      await prefs.remove(_cacheTimestampKey);
      debugPrint('✅ Cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Cache history data
  Future<void> cacheHistoryData(List<WaterData> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history.map((data) {
        return {
          'deviceId': data.deviceId,
          'status': data.status,
          'ph': data.ph,
          'tds': data.tds,
          'turbidity': data.turbidity,
          'temperature': data.temperature,
          'timestamp': data.timestamp.toIso8601String(),
        };
      }).toList();

      await prefs.setString('history_cache', json.encode(historyJson));
      debugPrint('✅ Cached ${history.length} historical readings');
    } catch (e) {
      debugPrint('❌ Error caching history data: $e');
    }
  }

  /// Get cached history data
  Future<List<WaterData>> getCachedHistoryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('history_cache');

      if (historyJson == null) {
        return [];
      }

      final historyList = json.decode(historyJson) as List<dynamic>;
      return historyList
          .map((item) => WaterData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error retrieving cached history: $e');
      return [];
    }
  }
}
