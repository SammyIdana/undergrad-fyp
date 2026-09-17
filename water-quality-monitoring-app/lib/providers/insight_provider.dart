import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/water_data.dart';
import '../utils/constants.dart';
import 'water_data_provider.dart';

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

// ─── Local Rule Engine (matching services/aiInsight.js) ────────────────────────

class _EvalResult {
  final String sev;
  final List<String> issues;
  final List<String> recs;
  _EvalResult(this.sev, this.issues, this.recs);
}

_EvalResult _evaluatePh(double ph) {
  final issues = <String>[];
  final recs = <String>[];
  String sev = 'normal';
  if (ph < 6.0 || ph > 9.0) {
    sev = 'critical';
    if (ph < 6.0) {
      issues.add('pH is critically low (${ph.toStringAsFixed(1)}) - highly acidic water');
      recs.add('Stop using this water immediately. Contact your water authority.');
    } else {
      issues.add('pH is critically high (${ph.toStringAsFixed(1)}) - strongly alkaline water');
      recs.add('Avoid drinking this water. Have it tested by a certified laboratory.');
    }
  } else if (ph < 6.5 || ph > 8.5) {
    sev = 'warning';
    if (ph < 6.5) {
      issues.add('pH is slightly acidic (${ph.toStringAsFixed(1)})');
      recs.add('Filter through a pH-balancing cartridge and retest within 24 hours.');
    } else {
      issues.add('pH is slightly alkaline (${ph.toStringAsFixed(1)})');
      recs.add('Monitor pH daily. Consult your water supplier if it continues rising.');
    }
  }
  return _EvalResult(sev, issues, recs);
}

_EvalResult _evaluateTds(double tds) {
  final issues = <String>[];
  final recs = <String>[];
  String sev = 'normal';
  if (tds > 1000) {
    sev = 'critical';
    issues.add('TDS is critically elevated (${tds.round()} ppm) - far above safe limits');
    recs.add('Do not drink this water. Use an RO filter or an alternative clean supply immediately.');
  } else if (tds > 600) {
    sev = 'warning';
    issues.add('TDS is high (${tds.round()} ppm) - exceeds the 600 ppm recommended limit');
    recs.add('Use a multi-stage filter to reduce dissolved solids before consumption.');
  } else if (tds > 300) {
    sev = 'minor';
    issues.add('TDS is moderately elevated (${tds.round()} ppm)');
    recs.add('Water is acceptable; a carbon block filter can improve taste.');
  }
  return _EvalResult(sev, issues, recs);
}

_EvalResult _evaluateTurbidity(double turb) {
  final issues = <String>[];
  final recs = <String>[];
  String sev = 'normal';
  if (turb > 4) {
    sev = 'critical';
    issues.add('Turbidity is very high (${turb.toStringAsFixed(1)} NTU) - water is visibly cloudy');
    recs.add('Do not consume this water. Use certified bottled water until clarity improves.');
    recs.add('Check for sediment buildup in pipes or a breach in the filtration system.');
  } else if (turb > 1) {
    sev = 'warning';
    issues.add('Turbidity is elevated (${turb.toStringAsFixed(1)} NTU) - above the ideal 1 NTU');
    recs.add('Flush the tap for 2-3 minutes. If cloudiness persists, replace filter cartridges.');
  }
  return _EvalResult(sev, issues, recs);
}

_EvalResult _evaluateTemperature(double temp) {
  final issues = <String>[];
  final recs = <String>[];
  String sev = 'normal';
  if (temp > 45 || temp < 0) {
    sev = 'critical';
    issues.add('Temperature is extreme (${temp.toStringAsFixed(1)} °C)');
    recs.add('Check sensor calibration. If accurate, inspect supply for contamination or heating faults.');
  } else if (temp > 35) {
    sev = 'warning';
    issues.add('Water temperature is elevated (${temp.toStringAsFixed(1)} °C) - promotes microbial growth');
    recs.add('Insulate and shade storage tanks. Elevated temperatures accelerate bacterial growth.');
  } else if (temp < 10) {
    sev = 'minor';
    issues.add('Water temperature is cool (${temp.toStringAsFixed(1)} °C) - below the optimal range');
    recs.add('Temperature is within safe limits. No corrective action required.');
  }
  return _EvalResult(sev, issues, recs);
}

const _sevRank = {'normal': 0, 'minor': 1, 'warning': 2, 'critical': 3};

String _maxSev(List<String> sevs) {
  return sevs.reduce((best, s) =>
      (_sevRank[s] ?? 0) > (_sevRank[best] ?? 0) ? s : best);
}

double _calcConfidence(String overallSev, String status) {
  final s = status.toUpperCase();
  const baseMap = {'normal': 0.92, 'minor': 0.88, 'warning': 0.85, 'critical': 0.90};
  double c = baseMap[overallSev] ?? 0.80;
  if (overallSev == 'critical' && (s == 'SAFE' || s == 'GOOD')) c -= 0.10;
  if (overallSev == 'normal' && s == 'DANGEROUS') c -= 0.08;
  return c.clamp(0.50, 1.0);
}

String _buildSummary(String overallSev, List<String> allIssues) {
  if (overallSev == 'normal') {
    return 'All monitored parameters are within safe ranges. The water is suitable for normal use.';
  }
  if (overallSev == 'minor') {
    return 'Water quality is generally acceptable with minor deviations. ${allIssues.isNotEmpty ? allIssues[0] : "Continue monitoring."}';
  }
  if (overallSev == 'warning') {
    final n = allIssues.length;
    final prefix = n > 1 ? '$n parameters are' : '1 parameter is';
    final items = allIssues.take(2).join('; ');
    return '$prefix outside the recommended range. Attention is advised: $items.';
  }
  return 'Critical water quality issue detected. ${allIssues.isNotEmpty ? allIssues[0] : "One or more parameters exceed safe thresholds."} Take corrective action before consuming this water.';
}

String _buildAssessment(String overallSev) {
  const map = {
    'normal': 'ACCEPTABLE',
    'minor': 'MONITOR',
    'warning': 'ATTENTION REQUIRED',
    'critical': 'UNSAFE - ACT NOW',
  };
  return map[overallSev] ?? 'UNKNOWN';
}

/// Generates an AI insight matching the backend rules
WaterInsight generateLocalInsight({
  required String deviceId,
  required double ph,
  required double tds,
  required double turbidity,
  required double temperature,
  required String status,
}) {
  final phR = _evaluatePh(ph);
  final tdsR = _evaluateTds(tds);
  final turbR = _evaluateTurbidity(turbidity);
  final tempR = _evaluateTemperature(temperature);

  final overallSev = _maxSev([phR.sev, tdsR.sev, turbR.sev, tempR.sev]);
  final allIssues = [...phR.issues, ...turbR.issues, ...tdsR.issues, ...tempR.issues];
  final allRecs = [...phR.recs, ...turbR.recs, ...tdsR.recs, ...tempR.recs];
  final uniqueRecs = allRecs.toSet().take(3).toList();

  return WaterInsight(
    deviceId: deviceId,
    status: status,
    assessment: _buildAssessment(overallSev),
    confidence: _calcConfidence(overallSev, status),
    recommendations: uniqueRecs.isNotEmpty
        ? uniqueRecs
        : const ['No immediate action required. Continue routine monitoring.'],
    summary: _buildSummary(overallSev, allIssues),
    generatedAt: DateTime.now(),
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

const Duration _insightTimeout = Duration(seconds: 4);

/// Fetches an AI insight for the configured device from the backend,
/// with automatic real-time streaming updates and an on-device rule engine fallback.
final insightProvider = FutureProvider<WaterInsight>((ref) async {
  // Watch waterDataProvider so the insight automatically recomputes when new telemetry arrives
  final AsyncValue<WaterData> waterDataAsync = ref.watch(waterDataProvider);
  final WaterData? latestWaterData = waterDataAsync.asData?.value;

  final endpoints = [
    '${AppConfig.backendBaseUrl}/api/telemetry/latest/${AppConfig.targetDeviceId}/insight',
    'https://water-quality-monitor-api.onrender.com/api/telemetry/latest/${AppConfig.targetDeviceId}/insight',
  ];

  for (final endpoint in endpoints) {
    try {
      final response = await http.get(Uri.parse(endpoint)).timeout(_insightTimeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return WaterInsight.fromJson(body);
      }
    } catch (_) {
      // Continue to next endpoint or fallback
    }
  }

  // Graceful fallback: generate insight directly from latest active telemetry
  if (latestWaterData != null && latestWaterData.status != 'WAITING') {
    return generateLocalInsight(
      deviceId: latestWaterData.deviceId,
      ph: latestWaterData.ph,
      tds: latestWaterData.tds,
      turbidity: latestWaterData.turbidity,
      temperature: latestWaterData.temperature,
      status: latestWaterData.status,
    );
  }

  return WaterInsight(
    deviceId: AppConfig.targetDeviceId,
    status: 'WAITING',
    assessment: 'MONITOR',
    confidence: 0.90,
    recommendations: const ['Awaiting telemetry packets from device.'],
    summary: 'Device connecting. Awaiting initial water quality readings.',
    generatedAt: DateTime.now(),
  );
});
