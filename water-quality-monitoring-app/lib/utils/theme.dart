import 'package:flutter/material.dart';
import 'constants.dart';

// Dark mode colors
class AppColorsDark {
  // Primary gradient colors (adjusted for dark mode)
  static const Color primary = Color(0xFF5BA3FF);
  static const Color primaryLight = Color(0xFF7BB7FF);
  static const Color primaryDark = Color(0xFF3B7FFF);
  
  // Background
  static const Color background = Color(0xFF0F1419);
  static const Color card = Color(0xFF1A202C);
  static const Color surfaceOverlay = Color(0xFF242D3F);
  
  // Text
  static const Color textMain = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  // Status colors with gradients (dark optimized)
  static const Color safe = Color(0xFF10B981); // Green
  static const Color safeLight = Color(0xFF1E6F5C);
  
  static const Color caution = Color(0xFFF59E0B); // Amber
  static const Color cautionLight = Color(0xFF6B4E05);
  
  static const Color limitedUse = Color(0xFFF97316); // Orange
  static const Color limitedUseLight = Color(0xFF7A3A1F);
  
  static const Color dangerous = Color(0xFFEF4444); // Red
  static const Color dangerousLight = Color(0xFF7A2121);
  
  // Accent colors
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color accentLight = Color(0xFF5B38B8);
}

class AppTheme {
  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      fontFamily: 'Inter',
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textMain,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColors.card,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      fontFamily: 'Inter',
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsDark.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColorsDark.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColorsDark.textMain,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: AppColorsDark.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColorsDark.card,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
