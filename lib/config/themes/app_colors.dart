import 'package:flutter/material.dart';

class AppColors {
  // extract ecc blue
  static const Color eccBlue = Color(0xff003399);
  // Primary Colors - Exact navy blue from web CSS
  static const Color primary = Color(0xFF05014A); // rgb(5, 1, 74) from web
  static const Color primaryVariant = Color(
    0xFF020047,
  ); // rgb(2, 0, 71) from web
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary Colors - Exact orange from web CSS
  static const Color secondary = Color(
    0xFFf88333,
  ); // rgb(248, 131, 51) from web
  static const Color secondaryVariant = Color(0xFFe6741f); // Darker orange
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background Colors - Light Theme (from web CSS)
  static const Color background = Color(
    0xFFf3f4f6,
  ); // rgb(243, 244, 246) from web
  static const Color onBackground = Color(0xFF213547); // From web root color
  static const Color surface = Color(0xFFFFFFFF); // Clean white
  static const Color onSurface = Color(0xFF213547);
  static const Color surfaceVariant = Color(0xFFf1f5f9); // Light blue-gray
  static const Color onSurfaceVariant = Color(0xFF64748b); // Medium gray

  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0f172a); // Dark navy
  static const Color onBackgroundDark = Color(0xFFf1f5f9);
  static const Color surfaceDark = Color(0xFF1e293b); // Dark blue-gray
  static const Color onSurfaceDark = Color(0xFFf1f5f9);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color onSurfaceVariantDark = Color(0xFF94a3b8);

  // Error Colors
  static const Color error = Color(0xFFef4444); // Modern red
  static const Color onError = Color(0xFFFFFFFF);

  // Success Colors
  static const Color success = Color(0xFF10b981); // Modern green
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Warning Colors
  static const Color warning = Color(0xFFf59e0b); // Modern amber
  static const Color onWarning = Color(0xFFFFFFFF);

  // Info Colors
  static const Color info = Color(0xFF3b82f6); // Modern blue
  static const Color onInfo = Color(0xFFFFFFFF);

  // Outline Colors
  static const Color outline = Color(0xFFe2e8f0); // Light border
  static const Color outlineDark = Color(0xFF475569); // Dark border

  // Text Colors - Light Theme (matching web)
  static const Color textPrimary = Color(0xFF213547); // From web root color
  static const Color textSecondary = Color(0xFF64748b); // Medium gray
  static const Color textDisabled = Color(0xFF94a3b8); // Light gray

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFf1f5f9); // Light text
  static const Color textSecondaryDark = Color(0xFF94a3b8); // Medium gray
  static const Color textDisabledDark = Color(0xFF64748b); // Darker gray

  // Special Colors
  static const Color divider = Color(0xFFe2e8f0);
  static const Color dividerDark = Color(0xFF475569);
  static const Color shadow = Color(0x1A05014A); // Navy shadow with opacity
  static const Color shadowDark = Color(0x40000000);

  // Status Colors - Updated to match new palette
  static const Color pending = Color(0xFFf59e0b); // Amber
  static const Color confirmed = Color(0xFF10b981); // Green
  static const Color cancelled = Color(0xFFef4444); // Red
  static const Color checkedIn = Color(0xFF05014A); // Exact web navy blue

  // Gradient Colors - Updated with new colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryVariant],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryVariant],
  );

  // Additional gradients for modern look
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFf8fafc), Color(0xFFe2e8f0)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFf8fafc)],
  );
}

