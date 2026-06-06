import 'package:flutter/material.dart';

/// Responsive breakpoints for the app
class ResponsiveBreakpoints {
  /// Mobile breakpoint (< 600px)
  static const double mobile = 600;

  /// Tablet breakpoint (600-1024px)
  static const double tablet = 1024;

  /// Desktop breakpoint (> 1024px)
  static const double desktop = 1024;
}

/// Responsive design utilities
class ResponsiveUtils {
  /// Check if screen size is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }

  /// Check if screen size is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  /// Check if screen size is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }

  /// Get grid column count based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    }
    return 2; // Mobile
  }

  /// Get horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 32;
    } else if (isTablet(context)) {
      return 24;
    }
    return 16; // Mobile
  }

  /// Get vertical padding based on screen size
  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 28;
    } else if (isTablet(context)) {
      return 20;
    }
    return 16; // Mobile
  }

  /// Get parameter card height based on screen size
  static double getCardHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 200;
    } else if (isTablet(context)) {
      return 180;
    }
    return 160; // Mobile
  }

  /// Get chart height based on screen size
  static double getChartHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 300;
    } else if (isTablet(context)) {
      return 260;
    }
    return 220; // Mobile
  }

  /// Get spacing between grid items
  static double getGridSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return 20;
    } else if (isTablet(context)) {
      return 16;
    }
    return 12; // Mobile
  }
}
