import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerDashboardLoader extends StatelessWidget {
  const ShimmerDashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1C1C21) : const Color(0xFFE4E8F0);
    final highlightColor = isDark ? const Color(0xFF2E2E38) : const Color(0xFFF5F7FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner skeleton
            _box(height: 136, radius: 24),
            const SizedBox(height: 28),
            // Section title
            _box(height: 20, width: 150, radius: 8),
            const SizedBox(height: 16),
            // 2x2 card grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.88,
              children: List.generate(4, (_) => _box(height: double.infinity, radius: 24)),
            ),
            const SizedBox(height: 28),
            // Timestamp chip
            _box(height: 58, radius: 16),
          ],
        ),
      ),
    );
  }

  Widget _box({required double height, double? width, double radius = 12}) {
    return Container(
      width: width ?? double.infinity,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ShimmerHistoryLoader extends StatelessWidget {
  const ShimmerHistoryLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1C1C21) : const Color(0xFFE4E8F0);
    final highlightColor = isDark ? const Color(0xFF2E2E38) : const Color(0xFFF5F7FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _box(height: 24, width: 130, radius: 8),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(4, (_) => _box(height: double.infinity, radius: 20)),
          ),
          const SizedBox(height: 28),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _box(height: 220, radius: 20),
          )),
        ],
      ),
    );
  }

  Widget _box({required double height, double? width, double radius = 12}) {
    return Container(
      width: width ?? double.infinity,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
