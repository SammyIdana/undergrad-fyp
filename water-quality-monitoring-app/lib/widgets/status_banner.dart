import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class StatusBanner extends StatelessWidget {
  final String status;
  const StatusBanner({super.key, required this.status});

  IconData _icon(String s) {
    switch (s.toUpperCase()) {
      case 'SAFE':
        return Icons.verified_rounded;
      case 'CAUTION':
        return Icons.warning_amber_rounded;
      case 'LIMITED USE':
        return Icons.error_outline_rounded;
      case 'DANGEROUS':
        return Icons.dangerous_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppHelpers.isDarkMode(context);
    final statusColor = AppHelpers.getStatusColorForTheme(status, context);
    final statusColorLight = AppHelpers.getStatusColorLightForTheme(status, context);
    final recommendation = AppHelpers.getStatusRecommendation(status);
    final isDangerous = status.toUpperCase() == 'DANGEROUS';

    final cardBg = isDark ? AppColorsDark.card : AppColors.card;
    final textMain = isDark ? AppColorsDark.textMain : AppColors.textMain;
    final textSub = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColorLight.withValues(alpha: isDark ? 0.35 : 0.25),
            statusColorLight.withValues(alpha: isDark ? 0.12 : 0.08),
          ],
        ),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.25 : 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDangerous ? 0.22 : 0.14),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDangerous
                        ? [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.3),
                              blurRadius: 18,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(_icon(status), color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Quality',
                        style: AppStyles.paramLabelStyle.copyWith(color: textSub),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: isDark ? 0.45 : 0.70),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Text(
                recommendation,
                textAlign: TextAlign.center,
                style: AppStyles.captionStyle.copyWith(
                  color: textMain,
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
