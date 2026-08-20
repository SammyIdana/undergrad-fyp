import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert_item.dart';
import '../utils/constants.dart';

class AlertService {
  static final String _baseUrl = AppConfig.backendBaseUrl;

  Future<List<AlertItem>> fetchAlerts() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/alerts'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load alerts: ${response.statusCode}');
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>? ?? [];
    return data.map((item) => AlertItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> markAlertRead(String alertId) async {
    final response = await http.post(Uri.parse('$_baseUrl/api/alerts/$alertId/read'));
    if (response.statusCode != 200) {
      throw Exception('Failed to mark alert read: ${response.statusCode}');
    }
  }
}
