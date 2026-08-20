import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_item.dart';
import '../services/alert_service.dart';

final alertListProvider = AsyncNotifierProvider<AlertListNotifier, List<AlertItem>>(
  () => AlertListNotifier(),
);

class AlertListNotifier extends AsyncNotifier<List<AlertItem>> {
  @override
  Future<List<AlertItem>> build() async {
    return fetchAlerts();
  }

  Future<List<AlertItem>> fetchAlerts() async {
    state = const AsyncValue.loading();
    final alerts = await AlertService().fetchAlerts();
    state = AsyncValue.data(alerts);
    return alerts;
  }

  Future<void> markAsRead(String alertId) async {
    await AlertService().markAlertRead(alertId);
    state = await AsyncValue.guard(() async {
      final alerts = await fetchAlerts();
      return alerts;
    });
  }
}
