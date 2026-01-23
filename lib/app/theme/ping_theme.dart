import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ping Design System - White/Red/Black Theme
/// Modern, bold color scheme with:
/// - Crimson red as primary accent
/// - Pure white/black for contrast
/// - Full dark mode support
class PingTheme {
  PingTheme._();

  // ============ LIGHT MODE COLORS ============

  // Brand Colors (Light)
  static const Color primaryRed = Color(0xFFDC143C); // Crimson red
  static const Color primaryRedLight =
      Color(0xFFFF6B6B); // Lighter red for hover
  static const Color primaryRedDark = Color(0xFFB91C1C); // Darker red

  // Status Colors (Light)
  static const Color statusDone = Color(0xFF10B981); // Green - completed
  static const Color statusSnoozed = Color(0xFFDC143C); // Red - snoozed
  static const Color statusSkipped = Color(0xFF6B7280); // Gray - skipped

  // Neutral palette (Light)
  static const Color bgLight = Color(0xFFF8F8F8); // Main background
  static const Color cardWhite = Color(0xFFFFFFFF); // Card surface
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark text
  static const Color textSecondary = Color(0xFF666666); // Muted text
  static const Color shadowLight = Color(0xFFFFFFFF); // Light shadow
  static const Color shadowDark = Color(0xFFE0E0E0); // Dark shadow
  static const Color borderLight = Color(0xFFE5E5E5); // Borders

  // ============ DARK MODE COLORS ============

  // Brand Colors (Dark)
  static const Color primaryRedDarkMode =
      Color(0xFFFF4757); // Brighter red for dark
  static const Color primaryRedLightDarkMode =
      Color(0xFFFF6B81); // Lighter variant

  // Status Colors (Dark)
  static const Color statusDoneDark = Color(0xFF34D399); // Brighter green
  static const Color statusSnoozedDark = Color(0xFFFF4757); // Bright red
  static const Color statusSkippedDark = Color(0xFF9CA3AF); // Light gray

  // Neutral palette (Dark)
  static const Color bgDark = Color(0xFF121212); // Main background
  static const Color cardDark = Color(0xFF1E1E1E); // Card surface
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Muted text
  static const Color shadowDarkMode = Color(0xFF000000); // Deep shadow
  static const Color borderDark = Color(0xFF2A2A2A); // Borders

  // ============ NEUMORPHIC DECORATIONS ============

  static BoxDecoration get neumorphicCard => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowDark.withAlpha(77),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          const BoxShadow(
            color: shadowLight,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      );

  static BoxDecoration get neumorphicCardDark => BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowDarkMode.withAlpha(128),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      );

  static BoxDecoration get neumorphicCardPressed => BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowDark.withAlpha(51),
            offset: const Offset(2, 2),
            blurRadius: 5,
            spreadRadius: -2,
          ),
        ],
      );

  static BoxDecoration neumorphicPill({bool selected = false, Color? color}) =>
      BoxDecoration(
        color: selected ? (color ?? primaryRed) : cardWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: selected
            ? null
            : [
                BoxShadow(
                  color: shadowDark.withAlpha(51),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
                const BoxShadow(
                  color: shadowLight,
                  offset: Offset(-2, -2),
                  blurRadius: 6,
                ),
              ],
      );

  // ============ MATERIAL THEME ============

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        secondary: primaryRedLight,
        surface: cardWhite,
        surfaceContainerHighest: bgLight,
        error: primaryRed,
      ),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardWhite,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardWhite,
        selectedColor: primaryRed,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgLight,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Dark theme with white/red/black color scheme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRedDarkMode,
        brightness: Brightness.dark,
        primary: primaryRedDarkMode,
        secondary: primaryRedLightDarkMode,
        surface: cardDark,
        surfaceContainerHighest: bgDark,
        error: primaryRedDarkMode,
      ),
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardDark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryRedDarkMode,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textSecondaryDark,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRedDarkMode,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primaryRedDarkMode,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardDark,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 70,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final textColor =
        brightness == Brightness.light ? textPrimary : textPrimaryDark;
    final secondaryColor =
        brightness == Brightness.light ? textSecondary : textSecondaryDark;

    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
    );
  }

  // ============ CUPERTINO THEME ============

  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryRed,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: bgLight,
      scaffoldBackgroundColor: bgLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryRed,
      ),
    );
  }
}

/// Extension for easy theme access
extension PingThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
}
