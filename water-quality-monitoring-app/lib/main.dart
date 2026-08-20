import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_service.dart';
import 'services/notification_manager.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService().initialize();

  runApp(
    const ProviderScope(
      child: WaterMonitoringApp(),
    ),
  );

  // Initialize notification registration and handlers after the UI is available.
  unawaited(NotificationManager.instance.initialize());
}

class WaterMonitoringApp extends ConsumerWidget {
  const WaterMonitoringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Monitor',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
