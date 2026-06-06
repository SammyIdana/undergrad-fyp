import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: AppStyles.headingStyle,
            ),
            SizedBox(height: 2),
            Text(
              'Customize your experience',
              style: AppStyles.captionStyle,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionTitle('Display'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 28),

            // Alert Thresholds Section
            _buildSectionTitle('Alert Thresholds'),
            const SizedBox(height: 12),
            _buildThresholdCard(
              'pH Level',
              'Safe: 6.5 - 8.5',
              Icons.science_rounded,
            ),
            const SizedBox(height: 12),
            _buildThresholdCard(
              'TDS (ppm)',
              'Safe: < 500',
              Icons.water_drop_rounded,
            ),
            const SizedBox(height: 12),
            _buildThresholdCard(
              'Turbidity (NTU)',
              'Safe: < 1.0',
              Icons.blur_on_rounded,
            ),
            const SizedBox(height: 12),
            _buildThresholdCard(
              'Temperature (°C)',
              'Safe: 15 - 35',
              Icons.thermostat_rounded,
            ),
            const SizedBox(height: 28),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications_rounded,
              title: 'Push Notifications',
              subtitle: 'Receive alerts for water quality changes',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification toggle
                },
              ),
            ),
            const SizedBox(height: 28),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Quality Monitor',
                      style: AppStyles.subtitleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: AppStyles.labelStyle.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Real-time water quality monitoring system with IoT integration. Monitor pH, TDS, turbidity, and temperature.',
                      style: AppStyles.labelStyle.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.titleStyle.copyWith(
        fontSize: 16,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.subtitleStyle),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.labelStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.subtitleStyle),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppStyles.labelStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_rounded,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color,
            ),
          ],
        ),
      ),
    );
  }
}
