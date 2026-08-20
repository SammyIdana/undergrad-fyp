import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  final bool pushEnabled;
  final bool quietHoursEnabled;
  final bool dailySummaryEnabled;
  final bool strictThresholdMode;

  NotificationPreferences({
    required this.pushEnabled,
    required this.quietHoursEnabled,
    required this.dailySummaryEnabled,
    required this.strictThresholdMode,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? quietHoursEnabled,
    bool? dailySummaryEnabled,
    bool? strictThresholdMode,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      strictThresholdMode: strictThresholdMode ?? this.strictThresholdMode,
    );
  }
}

class NotificationPreferencesService {
  static const String _keyPushEnabled = 'push_enabled';
  static const String _keyQuietHours = 'quiet_hours_enabled';
  static const String _keyDailySummary = 'daily_summary_enabled';
  static const String _keyStrictThreshold = 'strict_threshold_mode';

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      pushEnabled: prefs.getBool(_keyPushEnabled) ?? true,
      quietHoursEnabled: prefs.getBool(_keyQuietHours) ?? false,
      dailySummaryEnabled: prefs.getBool(_keyDailySummary) ?? true,
      strictThresholdMode: prefs.getBool(_keyStrictThreshold) ?? false,
    );
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushEnabled, preferences.pushEnabled);
    await prefs.setBool(_keyQuietHours, preferences.quietHoursEnabled);
    await prefs.setBool(_keyDailySummary, preferences.dailySummaryEnabled);
    await prefs.setBool(_keyStrictThreshold, preferences.strictThresholdMode);
  }
}
