import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class StatusBanner extends StatefulWidget {
  final String status;

  const StatusBanner({super.key, required this.status});

  @override
  State<StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<StatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(StatusBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getStatusColorForTheme(widget.status, context);
    final statusColorLight = AppHelpers.getStatusColorLightForTheme(widget.status, context);
    final recommendation = AppHelpers.getStatusRecommendation(widget.status);
    final statusIcon = _getStatusIcon(widget.status);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColorLight.withValues(alpha: 0.3),
                  statusColorLight.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated status indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing background
                          if (widget.status.toUpperCase() == 'DANGEROUS')
                            ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.3)
                                  .animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          // Icon container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Water Quality',
                              style: AppStyles.labelStyle.copyWith(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.status.toUpperCase(),
                                style: AppStyles.titleStyle.copyWith(
                                  color: statusColor,
                                  fontSize: 22,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Recommendation
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation,
                      textAlign: TextAlign.center,
                      style: AppStyles.subtitleStyle.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get appropriate icon based on status
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return Icons.check_circle_rounded;
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
}
