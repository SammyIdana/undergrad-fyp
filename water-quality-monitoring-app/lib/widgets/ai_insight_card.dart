import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insight_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

/// AI Insight Card — shown on DashboardScreen below the parameter grid.
/// Renders a loading shimmer, the insight content, or a graceful error fallback.
class AiInsightCard extends ConsumerWidget {
  const AiInsightCard({super.key});

  // ─── Assessment colour mapping ─────────────────────────────────────────────

  Color _assessmentColor(String assessment, bool isDark) {
    final a = assessment.toUpperCase();
    if (a.contains('UNSAFE') || a.contains('ACT NOW')) {
      return isDark ? AppColorsDark.dangerous : AppColors.dangerous;
    }
    if (a.contains('ATTENTION')) {
      return isDark ? AppColorsDark.caution : AppColors.caution;
    }
    if (a == 'MONITOR') {
      return isDark ? AppColorsDark.limitedUse : AppColors.limitedUse;
    }
    // ACCEPTABLE
    return isDark ? AppColorsDark.safe : AppColors.safe;
  }

  Color _assessmentColorLight(String assessment, bool isDark) {
    final a = assessment.toUpperCase();
    if (a.contains('UNSAFE') || a.contains('ACT NOW')) {
      return isDark ? AppColorsDark.dangerousLight : AppColors.dangerousLight;
    }
    if (a.contains('ATTENTION')) {
      return isDark ? AppColorsDark.cautionLight : AppColors.cautionLight;
    }
    if (a == 'MONITOR') {
      return isDark ? AppColorsDark.limitedUseLight : AppColors.limitedUseLight;
    }
    return isDark ? AppColorsDark.safeLight : AppColors.safeLight;
  }

  IconData _assessmentIcon(String assessment) {
    final a = assessment.toUpperCase();
    if (a.contains('UNSAFE') || a.contains('ACT NOW')) return Icons.dangerous_rounded;
    if (a.contains('ATTENTION')) return Icons.warning_amber_rounded;
    if (a == 'MONITOR') return Icons.visibility_rounded;
    return Icons.verified_rounded;
  }

  // ─── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final base  = isDark ? AppColorsDark.card : AppColors.card;
    final shine = isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: base,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: shine, borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 90, height: 10, decoration: BoxDecoration(color: shine, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 6),
              Container(width: 140, height: 14, decoration: BoxDecoration(color: shine, borderRadius: BorderRadius.circular(6))),
            ]),
          ]),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 10, decoration: BoxDecoration(color: shine, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 6),
          Container(width: double.infinity * 0.8, height: 10, decoration: BoxDecoration(color: shine, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 6),
          Container(width: 200, height: 10, decoration: BoxDecoration(color: shine, borderRadius: BorderRadius.circular(6))),
        ],
      ),
    );
  }

  Widget _buildError(Object err, bool isDark) {
    final errColor  = isDark ? AppColorsDark.dangerous : AppColors.dangerous;
    final cardBg    = isDark ? AppColorsDark.card       : AppColors.card;
    final textSub   = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardBg,
        border: Border.all(color: errColor.withValues(alpha: 0.30), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: errColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cloud_off_rounded, color: errColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insight Unavailable',
                    style: AppStyles.labelStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: errColor,
                        fontSize: 13)),
                const SizedBox(height: 3),
                Text('Could not reach the insight endpoint. Check your backend connection.',
                    style: AppStyles.captionStyle.copyWith(color: textSub, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WaterInsight insight, bool isDark) {
    final accentColor  = _assessmentColor(insight.assessment, isDark);
    final accentLight  = _assessmentColorLight(insight.assessment, isDark);
    final cardBg       = isDark ? AppColorsDark.card       : AppColors.card;
    final surfaceOvr   = isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay;
    final textMain     = isDark ? AppColorsDark.textMain   : AppColors.textMain;
    final textSub      = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Confidence bar width (0.0 → 1.0)
    final confidence   = insight.confidence.clamp(0.0, 1.0);
    final pct          = (confidence * 100).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentLight.withValues(alpha: isDark ? 0.30 : 0.18),
            accentLight.withValues(alpha: isDark ? 0.10 : 0.06),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.32),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.18),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(_assessmentIcon(insight.assessment),
                      color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI WATER INSIGHT',
                          style: AppStyles.paramLabelStyle.copyWith(
                            color: textSub,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          insight.assessment,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: isDark ? 0.55 : 0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('$pct%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                            letterSpacing: -0.5,
                          )),
                      Text('conf.',
                          style: AppStyles.paramLabelStyle.copyWith(
                            fontSize: 8, color: textSub,
                          )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Confidence bar ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 4,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),

            const SizedBox(height: 16),

            // ── Summary ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: isDark ? 0.50 : 0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Text(
                insight.summary,
                style: AppStyles.captionStyle.copyWith(
                  color: textMain,
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 14),

              // ── Recommendations ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surfaceOvr.withValues(alpha: isDark ? 0.40 : 0.60),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.tips_and_updates_rounded,
                          size: 14, color: accentColor),
                      const SizedBox(width: 6),
                      Text('RECOMMENDATIONS',
                          style: AppStyles.paramLabelStyle.copyWith(
                            color: accentColor, fontSize: 9, letterSpacing: 1.1,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    ...insight.recommendations.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final rec = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: idx < insight.recommendations.length ? 8.0 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20, height: 20,
                              margin: const EdgeInsets.only(top: 1, right: 8),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('$idx',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Text(rec,
                                  style: AppStyles.captionStyle.copyWith(
                                    color: textMain,
                                    fontSize: 12,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Footer timestamp ─────────────────────────────────────────────
            Text(
              'Generated ${insight.generatedAt.toLocal().toString().split('.')[0]}',
              style: AppStyles.paramLabelStyle.copyWith(
                color: textSub, fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark        = AppHelpers.isDarkMode(context);
    final asyncInsight  = ref.watch(insightProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'AI Analysis',
          style: AppStyles.titleStyle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),

        asyncInsight.when(
          data:    (insight) => _buildContent(insight, isDark),
          loading: ()        => _buildSkeleton(isDark),
          error:   (err, _)  => _buildError(err, isDark),
        ),
      ],
    );
  }
}
