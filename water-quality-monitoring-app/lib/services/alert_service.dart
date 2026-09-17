import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert_item.dart';
import '../utils/constants.dart';

class AlertService {
  static final String _baseUrl = AppConfig.backendBaseUrl;
  static const String _cloudUrl = 'https://water-quality-monitor-api.onrender.com';

  Future<List<AlertItem>> fetchAlerts() async {
    final urls = [
      '$_baseUrl/api/alerts',
      '$_cloudUrl/api/alerts',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          final data = decoded['data'] as List<dynamic>? ?? [];
          return data.map((item) => AlertItem.fromJson(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // Try next fallback
      }
    }
    return [];
  }

  Future<void> markAlertRead(String alertId) async {
    final urls = [
      '$_baseUrl/api/alerts/$alertId/read',
      '$_cloudUrl/api/alerts/$alertId/read',
    ];

    for (final url in urls) {
      try {
        final response = await http.post(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return;
      } catch (_) {
        // Continue to fallback
      }
    }
  }
}
