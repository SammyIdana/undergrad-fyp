import 'package:flutter/material.dart';
import 'constants.dart';
import 'theme.dart';

class AppHelpers {
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return AppColors.safe;
      case 'CAUTION':
        return AppColors.caution;
      case 'LIMITED USE':
        return AppColors.limitedUse;
      case 'DANGEROUS':
        return AppColors.dangerous;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color getStatusColorLight(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return AppColors.safeLight;
      case 'CAUTION':
        return AppColors.cautionLight;
      case 'LIMITED USE':
        return AppColors.limitedUseLight;
      case 'DANGEROUS':
        return AppColors.dangerousLight;
      default:
        return AppColors.textSecondary;
    }
  }

  static String getStatusRecommendation(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return 'Water quality is excellent. Safe for drinking and all uses.';
      case 'CAUTION':
        return 'Exercise caution. Not safe for drinking, but usable for cooking with boiling.';
      case 'LIMITED USE':
        return 'Limited use recommended. Suitable only for washing and cleaning purposes.';
      case 'DANGEROUS':
        return 'Water is unsafe. Do not use for any purposes including drinking, cooking, or washing.';
      default:
        return 'Waiting for sensor data...';
    }
  }

  static IconData getParameterIcon(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'ph':
        return Icons.science_rounded;
      case 'tds':
        return Icons.water_drop_rounded;
      case 'turbidity':
        return Icons.blur_on_rounded;
      case 'temperature':
        return Icons.thermostat_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Dark mode aware helper methods
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getStatusColorForTheme(String status, BuildContext context) {
    if (isDarkMode(context)) {
      switch (status.toUpperCase()) {
        case 'SAFE':
          return AppColorsDark.safe;
        case 'CAUTION':
          return AppColorsDark.caution;
        case 'LIMITED USE':
          return AppColorsDark.limitedUse;
        case 'DANGEROUS':
          return AppColorsDark.dangerous;
        default:
          return AppColorsDark.textSecondary;
      }
    }
    return getStatusColor(status);
  }

  static Color getStatusColorLightForTheme(String status, BuildContext context) {
    if (isDarkMode(context)) {
      switch (status.toUpperCase()) {
        case 'SAFE':
          return AppColorsDark.safeLight;
        case 'CAUTION':
          return AppColorsDark.cautionLight;
        case 'LIMITED USE':
          return AppColorsDark.limitedUseLight;
        case 'DANGEROUS':
          return AppColorsDark.dangerousLight;
        default:
          return AppColorsDark.textSecondary;
      }
    }
    return getStatusColorLight(status);
  }
}
