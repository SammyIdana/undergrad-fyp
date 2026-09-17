import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_data.dart';
import '../providers/chat_provider.dart';
import '../providers/water_data_provider.dart';
import '../screens/ai_chat_screen.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

/// AI Assistant Card — displayed on the DashboardScreen.
/// Replaces the old static insight card with an active, interactive launcher.
class AiAssistantCard extends ConsumerWidget {
  const AiAssistantCard({super.key});

  void _openChatWithPrompt(BuildContext context, WidgetRef ref, String prompt, WaterData? waterData) {
    ref.read(chatProvider.notifier).sendUserMessage(prompt, currentData: waterData);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiChatScreen()),
    );
  }

  void _openChatWithDiagnosis(BuildContext context, WidgetRef ref, WaterData waterData) {
    ref.read(chatProvider.notifier).diagnoseTelemetry(waterData);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppHelpers.isDarkMode(context);
    final waterDataAsync = ref.watch(waterDataProvider);
    final waterData = waterDataAsync.asData?.value;

    final cardBg = isDark ? AppColorsDark.card : AppColors.card;
    final textMain = isDark ? AppColorsDark.textMain : AppColors.textMain;
    final textSub = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    final hasAnomaly = waterData != null &&
        (waterData.status == 'UNSAFE' ||
            waterData.status == 'DANGEROUS' ||
            waterData.status == 'CAUTION' ||
            waterData.turbidity > 4.0 ||
            waterData.ph < 6.0 ||
            waterData.ph > 9.0 ||
            waterData.tds > 1000.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'AI Assistant',
              style: AppStyles.titleStyle.copyWith(fontSize: 22),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'Open Chat',
                style: AppStyles.labelStyle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasAnomaly
                  ? AppColors.caution.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                hasAnomaly
                    ? AppColors.caution.withValues(alpha: isDark ? 0.12 : 0.06)
                    : AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.05),
                cardBg,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasAnomaly
                            ? [AppColors.caution, AppColors.limitedUse]
                            : [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (hasAnomaly ? AppColors.caution : AppColors.primary)
                              .withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Water Quality Chatbot',
                              style: AppStyles.headingStyle.copyWith(
                                fontSize: 16,
                                color: textMain,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.safe.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.circle, color: AppColors.safe, size: 6),
                                  SizedBox(width: 4),
                                  Text(
                                    'ONLINE',
                                    style: TextStyle(
                                      color: AppColors.safe,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Analyze causes & corrective actions for alerts and sensor changes',
                          style: AppStyles.captionStyle.copyWith(
                            color: textSub,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Quality alert badge if anomaly detected
              if (hasAnomaly) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.caution.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.caution.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.caution, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Detected abnormal quality levels (${waterData.status}). Tap below to analyze causes and corrective actions.',
                          style: AppStyles.captionStyle.copyWith(
                            color: textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Main CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasAnomaly ? AppColors.caution : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (waterData != null && waterData.status != 'WAITING') {
                      _openChatWithDiagnosis(context, ref, waterData);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AiChatScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.troubleshoot_rounded, size: 20),
                  label: Text(
                    hasAnomaly ? 'Diagnose Critical Quality Anomaly' : 'Diagnose Current Water Quality',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick prompt chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickPill(
                    context,
                    ref,
                    'Why is turbidity high?',
                    waterData,
                    isDark,
                  ),
                  _buildQuickPill(
                    context,
                    ref,
                    'Is water safe to drink?',
                    waterData,
                    isDark,
                  ),
                  _buildQuickPill(
                    context,
                    ref,
                    'How to lower TDS?',
                    waterData,
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPill(
    BuildContext context,
    WidgetRef ref,
    String prompt,
    WaterData? waterData,
    bool isDark,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openChatWithPrompt(context, ref, prompt, waterData),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              prompt,
              style: AppStyles.captionStyle.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
