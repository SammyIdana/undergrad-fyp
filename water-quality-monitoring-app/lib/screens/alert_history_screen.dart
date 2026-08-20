import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alert_provider.dart';
import '../utils/constants.dart';

class AlertHistoryScreen extends ConsumerWidget {
  const AlertHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertState = ref.watch(alertListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Alert History', style: AppStyles.headingStyle),
      ),
      body: alertState.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Text(
                'No alerts have been received yet.',
                style: AppStyles.subtitleStyle.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final badgeColor = alert.severity == 'critical'
                  ? AppColors.dangerous
                  : alert.severity == 'warning'
                      ? AppColors.caution
                      : AppColors.safe;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert.severity.toUpperCase(),
                              style: AppStyles.paramLabelStyle.copyWith(color: badgeColor),
                            ),
                          ),
                          const Spacer(),
                          if (!alert.read)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: AppStyles.paramLabelStyle.copyWith(color: AppColors.primary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(alert.message, style: AppStyles.subtitleStyle),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            alert.deviceId,
                            style: AppStyles.captionStyle.copyWith(color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            alert.sentAt.toLocal().toString().split('.')[0],
                            style: AppStyles.captionStyle.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (alert.active)
                            Text(
                              'Active',
                              style: AppStyles.labelStyle.copyWith(color: badgeColor),
                            )
                          else
                            Text(
                              'Resolved',
                              style: AppStyles.labelStyle.copyWith(color: AppColors.safe),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: alert.read
                                ? null
                                : () async {
                                    await ref.read(alertListProvider.notifier).markAsRead(alert.id);
                                  },
                            child: const Text('Mark as read'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Unable to load alerts: $err', style: AppStyles.captionStyle),
        ),
      ),
    );
  }
}
