import 'package:flutter/material.dart';

// ─── Light Mode Palette ───────────────────────────────────────────────────────
class AppColors {
  static const Color primary      = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF5DDEC5);
  static const Color primaryDark  = Color(0xFF008C7A);

  static const Color background     = Color(0xFFF2F5FA);
  static const Color card           = Color(0xFFFFFFFF);
  static const Color surfaceOverlay = Color(0xFFF7F9FE);
  static const Color surface2       = Color(0xFFEDF0F8);

  static const Color textMain      = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary  = Color(0xFF9CA3AF);

  static const Color safe            = Color(0xFF10B981);
  static const Color safeLight       = Color(0xFFD1FAE5);
  static const Color caution         = Color(0xFFF59E0B);
  static const Color cautionLight    = Color(0xFFFEF3C7);
  static const Color limitedUse      = Color(0xFFF97316);
  static const Color limitedUseLight = Color(0xFFFFEDD5);
  static const Color dangerous       = Color(0xFFEF4444);
  static const Color dangerousLight  = Color(0xFFFEE2E2);

  static const Color accent      = Color(0xFF818CF8);
  static const Color accentLight = Color(0xFFEDE9FE);

  // Per-parameter premium chart colors
  static const Color phColor          = Color(0xFF00D4AA);
  static const Color tdsColor         = Color(0xFF818CF8);
  static const Color turbidityColor   = Color(0xFFFB923C);
  static const Color temperatureColor = Color(0xFFF472B6);
}

// ─── Dark Mode Palette ────────────────────────────────────────────────────────
class AppColorsDark {
  static const Color primary      = Color(0xFF00E5C4);
  static const Color primaryLight = Color(0xFF60F0DB);
  static const Color primaryDark  = Color(0xFF00B8A0);

  // Obsidian → Slate → Charcoal
  static const Color background     = Color(0xFF121214);
  static const Color card           = Color(0xFF1C1C21);
  static const Color surfaceOverlay = Color(0xFF26262D);
  static const Color surface2       = Color(0xFF2E2E38);

  static const Color textMain      = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary  = Color(0xFF6B7280);

  static const Color safe            = Color(0xFF34D399);
  static const Color safeLight       = Color(0xFF064E3B);
  static const Color caution         = Color(0xFFFBBF24);
  static const Color cautionLight    = Color(0xFF3D2500);
  static const Color limitedUse      = Color(0xFFFB923C);
  static const Color limitedUseLight = Color(0xFF431407);
  static const Color dangerous       = Color(0xFFF87171);
  static const Color dangerousLight  = Color(0xFF450A0A);

  static const Color accent      = Color(0xFFA78BFA);
  static const Color accentLight = Color(0xFF2E1065);
}

class AppConfig {
  // Update this to your PC's LAN IP when running on a real device.
  // Example: 'http://192.168.1.120:5000'
  static const String backendBaseUrl = 'http://10.0.2.2:5000';
  static const String targetDeviceId = 'ESP32_221A74';
}

// ─── Type Scale ───────────────────────────────────────────────────────────────
class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.4,
    height: 1.3,
  );

  // Hero display number for sensor metrics
  static const TextStyle metricValueStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textMain,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -1.0,
  );

  // Small-caps label for parameter names
  static const TextStyle paramLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
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
    height: 1.4,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );
}
