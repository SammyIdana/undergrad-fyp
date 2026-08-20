import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isDarkCtx = AppHelpers.isDarkMode(context);

    final primary  = isDarkCtx ? AppColorsDark.primary : AppColors.primary;
    final textMain = isDarkCtx ? AppColorsDark.textMain : AppColors.textMain;
    final textSub  = isDarkCtx ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final cardBg   = isDarkCtx ? AppColorsDark.card : AppColors.card;
    final overlay  = isDarkCtx ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings',
                style: AppStyles.headingStyle.copyWith(color: textMain)),
            const SizedBox(height: 2),
            Text('Customize your experience',
                style: AppStyles.captionStyle.copyWith(color: textSub)),
          ],
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: primary,
            style: IconButton.styleFrom(
              backgroundColor: primary.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── DISPLAY ────────────────────────────────────────────────
            _sectionLabel('DISPLAY', textSub),
            const SizedBox(height: 10),
            _groupCard(
              isDarkCtx: isDarkCtx, cardBg: cardBg, overlay: overlay,
              children: [
                _switchRow(
                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF818CF8),
                  title: 'Dark Mode',
                  subtitle: isDark ? 'Obsidian theme active' : 'Light theme active',
                  value: isDark,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  textMain: textMain,
                  textSub: textSub,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── ALERT THRESHOLDS ───────────────────────────────────────
            _sectionLabel('ALERT THRESHOLDS', textSub),
            const SizedBox(height: 10),
            _groupCard(
              isDarkCtx: isDarkCtx, cardBg: cardBg, overlay: overlay,
              children: [
                _thresholdRow(
                  icon: Icons.science_rounded,
                  accentColor: AppColors.phColor,
                  title: 'pH Level',
                  range: 'Safe: 6.5 – 8.5',
                  textMain: textMain, textSub: textSub,
                ),
                _divider(isDarkCtx),
                _thresholdRow(
                  icon: Icons.water_drop_rounded,
                  accentColor: AppColors.tdsColor,
                  title: 'TDS',
                  range: 'Safe: < 300 ppm',
                  textMain: textMain, textSub: textSub,
                ),
                _divider(isDarkCtx),
                _thresholdRow(
                  icon: Icons.blur_on_rounded,
                  accentColor: AppColors.turbidityColor,
                  title: 'Turbidity',
                  range: 'Safe: < 1.0 NTU',
                  textMain: textMain, textSub: textSub,
                ),
                _divider(isDarkCtx),
                _thresholdRow(
                  icon: Icons.thermostat_rounded,
                  accentColor: AppColors.temperatureColor,
                  title: 'Temperature',
                  range: 'Safe: 15 – 35 °C',
                  textMain: textMain, textSub: textSub,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── NOTIFICATIONS ──────────────────────────────────────────
            _sectionLabel('NOTIFICATIONS', textSub),
            const SizedBox(height: 10),
            _groupCard(
              isDarkCtx: isDarkCtx, cardBg: cardBg, overlay: overlay,
              children: [
                _switchRow(
                  icon: Icons.notifications_rounded,
                  iconColor: AppColors.caution,
                  title: 'Push Notifications',
                  subtitle: 'Alerts for water quality changes',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  textMain: textMain,
                  textSub: textSub,
                ),
                _divider(isDarkCtx),
                _switchRow(
                  icon: Icons.nightlight_round_rounded,
                  iconColor: AppColors.accent,
                  title: 'Quiet Hours',
                  subtitle: 'Suppress non-critical alerts during rest hours',
                  value: false,
                  onChanged: (v) {},
                  textMain: textMain,
                  textSub: textSub,
                ),
                _divider(isDarkCtx),
                _switchRow(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.phColor,
                  title: 'Daily Summary',
                  subtitle: 'Receive a daily report each morning',
                  value: true,
                  onChanged: (v) {},
                  textMain: textMain,
                  textSub: textSub,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── ABOUT ──────────────────────────────────────────────────
            _sectionLabel('ABOUT', textSub),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.phColor.withValues(alpha: isDarkCtx ? 0.15 : 0.08),
                    AppColors.tdsColor.withValues(alpha: isDarkCtx ? 0.08 : 0.04),
                  ],
                ),
                border: Border.all(
                  color: AppColors.phColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.phColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.water_rounded,
                        color: AppColors.phColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Water Monitor',
                            style: AppStyles.subtitleStyle.copyWith(color: textMain)),
                        const SizedBox(height: 4),
                        Text('IoT Water Quality Monitoring System',
                            style: AppStyles.captionStyle.copyWith(color: textSub)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.phColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('v1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.phColor,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label,
          style: AppStyles.paramLabelStyle.copyWith(color: color, fontSize: 11)),
    );
  }

  Widget _groupCard({
    required bool isDarkCtx,
    required Color cardBg,
    required Color overlay,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardBg, Color.lerp(cardBg, overlay, 0.6)!],
        ),
        border: Border.all(
          color: (isDarkCtx ? Colors.white : Colors.black).withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkCtx ? 0.12 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textMain,
    required Color textSub,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppStyles.subtitleStyle
                        .copyWith(color: textMain, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppStyles.captionStyle.copyWith(color: textSub)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _thresholdRow({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String range,
    required Color textMain,
    required Color textSub,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Colored left-bar accent
          Container(
            width: 3.5,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppStyles.subtitleStyle
                        .copyWith(color: textMain, fontSize: 15)),
                const SizedBox(height: 2),
                Text(range,
                    style: AppStyles.captionStyle.copyWith(color: textSub)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textSub, size: 20),
        ],
      ),
    );
  }
}
