import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class ParameterCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double numericValue;

  const ParameterCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.numericValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppHelpers.isDarkMode(context);
    final paramStatus = AppHelpers.getParameterStatus(title, numericValue);
    final statusColor = AppHelpers.getStatusColorForTheme(paramStatus, context);
    final paramColor = AppHelpers.getParameterColor(title);

    final cardBg = isDark ? AppColorsDark.card : AppColors.card;
    final overlay = isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay;
    final textMain = isDark ? AppColorsDark.textMain : AppColors.textMain;
    final textSub = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardBg, Color.lerp(cardBg, overlay, 0.7)!],
        ),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.38),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.22 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: paramColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(AppHelpers.getParameterIcon(title), color: paramColor, size: 22),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: 0.95),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: AppStyles.paramLabelStyle.copyWith(color: textSub),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppStyles.metricValueStyle.copyWith(color: textMain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: AppStyles.paramLabelStyle.copyWith(fontSize: 12, color: textSub),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                paramStatus,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
