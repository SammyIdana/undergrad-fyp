import 'package:flutter/material.dart';
import 'constants.dart';

class AppHelpers {
  // ─── Status color helpers ─────────────────────────────────────────────────

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE': return AppColors.safe;
      case 'CAUTION': return AppColors.caution;
      case 'LIMITED USE': return AppColors.limitedUse;
      case 'DANGEROUS': return AppColors.dangerous;
      default: return AppColors.textSecondary;
    }
  }

  static Color getStatusColorLight(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE': return AppColors.safeLight;
      case 'CAUTION': return AppColors.cautionLight;
      case 'LIMITED USE': return AppColors.limitedUseLight;
      case 'DANGEROUS': return AppColors.dangerousLight;
      default: return AppColors.textSecondary;
    }
  }

  static Color getStatusColorForTheme(String status, BuildContext context) {
    if (isDarkMode(context)) {
      switch (status.toUpperCase()) {
        case 'SAFE': return AppColorsDark.safe;
        case 'CAUTION': return AppColorsDark.caution;
        case 'LIMITED USE': return AppColorsDark.limitedUse;
        case 'DANGEROUS': return AppColorsDark.dangerous;
        default: return AppColorsDark.textSecondary;
      }
    }
    return getStatusColor(status);
  }

  static Color getStatusColorLightForTheme(String status, BuildContext context) {
    if (isDarkMode(context)) {
      switch (status.toUpperCase()) {
        case 'SAFE': return AppColorsDark.safeLight;
        case 'CAUTION': return AppColorsDark.cautionLight;
        case 'LIMITED USE': return AppColorsDark.limitedUseLight;
        case 'DANGEROUS': return AppColorsDark.dangerousLight;
        default: return AppColorsDark.textSecondary;
      }
    }
    return getStatusColorLight(status);
  }

  static String getStatusRecommendation(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return 'Water quality is excellent. Safe for drinking and all uses.';
      case 'CAUTION':
        return 'Exercise caution. Not ideal for drinking — boil before use.';
      case 'LIMITED USE':
        return 'Limited use only. Suitable for washing and cleaning purposes.';
      case 'DANGEROUS':
        return 'Water is unsafe. Do not use for any purpose whatsoever.';
      default:
        return 'Waiting for sensor data to be received...';
    }
  }

  // ─── Parameter helpers ────────────────────────────────────────────────────

  static IconData getParameterIcon(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'ph': return Icons.science_rounded;
      case 'tds': return Icons.water_drop_rounded;
      case 'turbidity': return Icons.blur_on_rounded;
      case 'temperature': return Icons.thermostat_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  static Color getParameterColor(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'ph': return AppColors.phColor;
      case 'tds': return AppColors.tdsColor;
      case 'turbidity': return AppColors.turbidityColor;
      case 'temperature': return AppColors.temperatureColor;
      default: return AppColors.primary;
    }
  }

  /// Compute per-parameter health status from its numeric reading
  static String getParameterStatus(String param, double value) {
    switch (param.toLowerCase()) {
      case 'ph':
        if (value >= 6.5 && value <= 8.5) return 'SAFE';
        if (value >= 6.0 && value <= 9.0) return 'CAUTION';
        return 'DANGEROUS';
      case 'tds':
        if (value < 300) return 'SAFE';
        if (value < 1000) return 'CAUTION';
        return 'DANGEROUS';
      case 'turbidity':
        if (value < 5.0) return 'SAFE';
        if (value < 25.0) return 'CAUTION';
        return 'DANGEROUS';
      case 'temperature':
        if (value >= 15 && value <= 35) return 'SAFE';
        if ((value >= 5 && value < 15) || (value > 35 && value <= 45)) return 'CAUTION';
        return 'DANGEROUS';
      default:
        return 'UNKNOWN';
    }
  }

  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
