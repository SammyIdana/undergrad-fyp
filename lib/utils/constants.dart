import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF5BA3FF);
  static const Color primaryDark = Color(0xFF0052CC);
  
  // Background
  static const Color background = Color(0xFFF8FAFF);
  static const Color card = Colors.white;
  static const Color surfaceOverlay = Color(0xFFFAFBFF);
  
  // Text
  static const Color textMain = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status colors with gradients
  static const Color safe = Color(0xFF10B981); // Green
  static const Color safeLight = Color(0xFFA7F3D0);
  
  static const Color caution = Color(0xFFF59E0B); // Amber
  static const Color cautionLight = Color(0xFFFEF3C7);
  
  static const Color limitedUse = Color(0xFFF97316); // Orange
  static const Color limitedUseLight = Color(0xFFFFEDD5);
  
  static const Color dangerous = Color(0xFFEF4444); // Red
  static const Color dangerousLight = Color(0xFFFEE2E2);
  
  // Accent colors
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color accentLight = Color(0xFFEDE9FE);
}

class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    letterSpacing: -0.5,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.3,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );
}
