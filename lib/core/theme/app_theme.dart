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

  static ThemeData lightTheme(double textScale, {int colorblindMode = 0}) {
    // Default Colors
    Color primaryColor = primary;
    // Color primaryDarkColor = primaryDark; // Unused
    Color primaryLightColor = primaryLight;
    Color errorColor = statusConflict;
    Color successColor = statusSafe;

    // Adjust dependent on mode
    // 1: Protanopia (Red-blind) -> Avoid red/green confusion. Blue/Yellow palette.
    if (colorblindMode == 1) {
      primaryColor = const Color(0xFF0077CC); // Strong Blue
      primaryLightColor = const Color(0xFFD6EBFF);
      errorColor = const Color(
        0xFFD55E00,
      ); // Vermilion/Orange (High contrast against blue)
      successColor = const Color(0xFF009E73); // Bluish Green (Teal)
    }
    // 2: Deuteranopia (Green-blind) -> Similar to Protanopia, focus on Blue/Orange differentiation
    else if (colorblindMode == 2) {
      primaryColor = const Color(0xFF332288); // Indigo
      primaryLightColor = const Color(0xFFEBE6FF);
      errorColor = const Color(0xFFD55E00); // Vermilion
      successColor = const Color(0xFF44AA99); // Teal
    }
    // 3: Tritanopia (Blue-blind) -> Avoid blue/yellow. Red/Cyan/Pink palette.
    else if (colorblindMode == 3) {
      primaryColor = const Color(0xFFCC3311); // Reddish Orange (Primary)
      primaryLightColor = const Color(0xFFFFEBE6);
      errorColor = const Color(0xFFEE3377); // Magenta
      successColor = const Color(0xFF009988); // Teal
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colors
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        secondary: successColor,
        error: errorColor,
        surface: surface,
        onSurface: textMain,
      ),

      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium(textScale),
        iconTheme: const IconThemeData(color: textMain, size: 24),
      ),

      // Elevated Buttons (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: buttonLarge(textScale),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: border, width: 2),
          textStyle: buttonLarge(textScale),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: buttonMedium(textScale),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: bodyMedium(textScale).copyWith(color: textLight),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: labelSmall(
          textScale,
        ).copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: labelSmall(textScale),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(color: textMain, size: 24),

      // Text Theme
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
      ),
    );
  }
}
