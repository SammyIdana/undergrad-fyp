import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class WaterInsight {
  final String deviceId;
  final String status;
  final String assessment;
  final double confidence;
  final List<String> recommendations;
  final String summary;
  final DateTime generatedAt;

  const WaterInsight({
    required this.deviceId,
    required this.status,
    required this.assessment,
    required this.confidence,
    required this.recommendations,
    required this.summary,
    required this.generatedAt,
  });

  factory WaterInsight.fromJson(Map<String, dynamic> json) {
    final d = json['data'] != null
        ? json['data'] as Map<String, dynamic>
        : json;
    return WaterInsight(
      deviceId:        d['deviceId']   as String? ?? '',
      status:          d['status']     as String? ?? '',
      assessment:      d['assessment'] as String? ?? 'UNKNOWN',
      confidence:      (d['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendations: (d['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      summary:     d['summary']     as String? ?? '',
      generatedAt: d['generatedAt'] != null
          ? DateTime.tryParse(d['generatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

const Duration _insightTimeout = Duration(seconds: 10);

/// Fetches an AI insight for the configured device from the backend.
/// Keyed off [AppConfig.targetDeviceId]. Returns a [WaterInsight] or throws.
final insightProvider = FutureProvider<WaterInsight>((ref) async {
  final url = Uri.parse(
    '${AppConfig.backendBaseUrl}/api/telemetry/latest/${AppConfig.targetDeviceId}/insight',
  );

  debugPrint('Fetching AI insight from: $url');

  try {
    final response = await http.get(url).timeout(_insightTimeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return WaterInsight.fromJson(body);
    } else if (response.statusCode == 404) {
      throw Exception('No readings found for device ${AppConfig.targetDeviceId}.');
    } else {
      throw Exception('Insight endpoint returned HTTP ${response.statusCode}.');
    }
  } catch (e) {
    debugPrint('AI insight fetch error: $e');
    rethrow;
  }
});
