import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dosely Design System
/// Based on UI examples with Lexend font, blue primary, accessibility focus
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ===================
  // COLOR PALETTE
  // ===================

  // Primary Blue
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryDark = Color(0xFF0B63C1);
  static const Color primaryLight = Color(0xFFE3F2FD);

  // Status Colors
  static const Color statusSafe = Color(0xFF15803D);
  static const Color statusSafeBg = Color(0xFFDCFCE7);
  static const Color statusCaution = Color(0xFFB45309);
  static const Color statusCautionBg = Color(0xFFFEF3C7);
  static const Color statusConflict = Color(0xFFBE123C);
  static const Color statusConflictBg = Color(0xFFFFE4E6);

  // Text Colors
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF334155);
  static const Color textLight = Color(0xFF64748B);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ===================
  // TEXT STYLES
  // ===================

  static final TextStyle _baseTextStyle = GoogleFonts.lexend();

  // Display - Big hero text
  static TextStyle displayLarge(double scale) => _baseTextStyle.copyWith(
    fontSize: 32 * scale,
    fontWeight: FontWeight.w800,
    color: textMain,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium(double scale) => _baseTextStyle.copyWith(
    fontSize: 28 * scale,
    fontWeight: FontWeight.w700,
    color: textMain,
    height: 1.2,
    letterSpacing: -0.3,
  );

  // Headlines
  static TextStyle headlineLarge(double scale) => _baseTextStyle.copyWith(
    fontSize: 24 * scale,
    fontWeight: FontWeight.w700,
    color: textMain,
    height: 1.3,
  );

  static TextStyle headlineMedium(double scale) => _baseTextStyle.copyWith(
    fontSize: 20 * scale,
    fontWeight: FontWeight.w600,
    color: textMain,
    height: 1.3,
  );

  static TextStyle headlineSmall(double scale) => _baseTextStyle.copyWith(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w600,
    color: textMain,
    height: 1.4,
  );

  // Body
  static TextStyle bodyLarge(double scale) => _baseTextStyle.copyWith(
    fontSize: 16 * scale,
    fontWeight: FontWeight.w500,
    color: textMain,
    height: 1.5,
  );

  static TextStyle bodyMedium(double scale) => _baseTextStyle.copyWith(
    fontSize: 14 * scale,
    fontWeight: FontWeight.w400,
    color: textSub,
    height: 1.5,
  );

  static TextStyle bodySmall(double scale) => _baseTextStyle.copyWith(
    fontSize: 12 * scale,
    fontWeight: FontWeight.w400,
    color: textLight,
    height: 1.5,
  );

  // Labels
  static TextStyle labelLarge(double scale) => _baseTextStyle.copyWith(
    fontSize: 14 * scale,
    fontWeight: FontWeight.w700,
    color: textMain,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium(double scale) => _baseTextStyle.copyWith(
    fontSize: 12 * scale,
    fontWeight: FontWeight.w600,
    color: textSub,
    letterSpacing: 0.3,
  );

  static TextStyle labelSmall(double scale) => _baseTextStyle.copyWith(
    fontSize: 10 * scale,
    fontWeight: FontWeight.w600,
    color: textLight,
    letterSpacing: 0.5,
    textBaseline: TextBaseline.alphabetic,
  );

  // Button text
  static TextStyle buttonLarge(double scale) => _baseTextStyle.copyWith(
    fontSize: 16 * scale,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static TextStyle buttonMedium(double scale) => _baseTextStyle.copyWith(
    fontSize: 14 * scale,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // ===================
  // THEME DATA
  // ===================

  static ThemeData lightTheme(
    double textScale, {
    int colorblindMode = 0,
    bool isHighContrast = false,
  }) {
    // Default Colors
    Color primaryColor = primary;
    Color primaryLightColor = primaryLight;
    Color errorColor = statusConflict;
    Color successColor = statusSafe;
    Color backgroundColor = background;
    Color surfaceColor = surface;
    Color textColor = textMain;

    // Colorblind Adjustments header...
    if (colorblindMode == 1) {
      primaryColor = const Color(0xFF0077CC);
      primaryLightColor = const Color(0xFFD6EBFF);
      errorColor = const Color(0xFFD55E00);
      successColor = const Color(0xFF009E73);
    } else if (colorblindMode == 2) {
      primaryColor = const Color(0xFF332288);
      primaryLightColor = const Color(0xFFEBE6FF);
      errorColor = const Color(0xFFD55E00);
      successColor = const Color(0xFF44AA99);
    } else if (colorblindMode == 3) {
      primaryColor = const Color(0xFFCC3311);
      primaryLightColor = const Color(0xFFFFEBE6);
      errorColor = const Color(0xFFEE3377);
      successColor = const Color(0xFF009988);
    }

    // High Contrast Overrides
    if (isHighContrast) {
      primaryColor = Colors.blue[900]!;
      primaryLightColor = Colors.blue[50]!;
      backgroundColor = Colors.white;
      surfaceColor = Colors.white;
      textColor = Colors.black;
      // errorColor and successColor keep their distinctive hues but could be darkened if needed
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        secondary: successColor,
        error: errorColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Apply scaled text styles via textTheme
      textTheme: TextTheme(
        displayLarge: displayLarge(textScale),
        displayMedium: displayMedium(textScale),
        headlineLarge: headlineLarge(textScale),
        headlineMedium: headlineMedium(textScale),
        headlineSmall: headlineSmall(textScale),
        bodyLarge: bodyLarge(textScale),
        bodyMedium: bodyMedium(textScale),
        bodySmall: bodySmall(textScale),
        labelLarge: labelLarge(textScale),
        labelMedium: labelMedium(textScale),
        labelSmall: labelSmall(textScale),
        titleMedium: headlineMedium(textScale), // Alias for convenience
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium(textScale).copyWith(color: textColor),
        iconTheme: IconThemeData(color: textColor, size: 24),
      ),
      // Outlined button styled to match elevated
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: primaryColor, width: 2),
          textStyle: buttonLarge(textScale),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: isHighContrast ? 4 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isHighContrast
                    ? const BorderSide(color: Colors.black, width: 2)
                    : BorderSide.none,
          ),
          textStyle: buttonLarge(textScale),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      // Global SnackBar theme - ensures auto-dismiss
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  static ThemeData darkTheme(
    double textScale, {
    int colorblindMode = 0,
    bool isHighContrast = false,
  }) {
    // Default Dark Colors
    Color primaryColor = const Color(0xFF60A5FA); // Lighter blue for dark mode
    Color primaryLightColor = const Color(0xFF1E3A8A);
    Color errorColor = const Color(0xFFF87171);
    Color successColor = const Color(0xFF4ADE80);
    Color backgroundColor = const Color(0xFF0F172A); // Dark Slate
    Color surfaceColor = const Color(0xFF1E293B);
    Color textColor = const Color(0xFFF8FAFC);

    // Colorblind Adjustments (Shifted for dark mode visibility)
    if (colorblindMode == 1) {
      primaryColor = const Color(0xFF56B4E9); // Sky Blue
      errorColor = const Color(0xFFE69F00); // Orange
    } else if (colorblindMode == 2) {
      primaryColor = const Color(0xFFCC79A7); // Reddish Purple
      errorColor = const Color(0xFFE69F00);
    } else if (colorblindMode == 3) {
      primaryColor = const Color(0xFFFF7C43);
      errorColor = const Color(0xFFFF4EA3); // Bright Pink
    }

    // High Contrast Overrides
    if (isHighContrast) {
      backgroundColor = Colors.black;
      surfaceColor = Colors.black;
      textColor = Colors.white;
      primaryColor = Colors.cyanAccent; // Very bright against black
      // specific high contrast logic
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.black, // Dark text on light primary in dark mode
        primaryContainer: primaryLightColor,
        secondary: successColor,
        error: errorColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium(textScale).copyWith(color: textColor),
        iconTheme: IconThemeData(color: textColor, size: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: isHighContrast ? 4 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isHighContrast
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
          ),
          textStyle: buttonLarge(textScale),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }
}
