import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ping Design System - Neumorphic Soft UI
/// Based on reference designs with:
/// - Soft shadows and rounded corners
/// - Mint green, dusty rose, and orange accents
/// - Clean white/off-white backgrounds
class PingTheme {
  PingTheme._();

  // Brand Colors
  static const Color primaryMint = Color(0xFF7EBDA4);      // Mint green
  static const Color primaryOrange = Color(0xFFFF7A50);    // Orange accent
  static const Color dustyRose = Color(0xFFC9A9A6);        // Dusty rose
  static const Color paleRose = Color(0xFFF5E6E5);         // Pale rose bg
  
  // Status Colors
  static const Color statusDone = Color(0xFF7EBDA4);       // Mint - completed
  static const Color statusSnoozed = Color(0xFFFF7A50);    // Orange - snoozed
  static const Color statusSkipped = Color(0xFF9E9E9E);    // Gray - skipped
  
  // Neutral palette (neumorphic)
  static const Color bgLight = Color(0xFFF5F5F7);          // Main background
  static const Color cardWhite = Color(0xFFFFFFFF);        // Card surface
  static const Color textPrimary = Color(0xFF2C3E50);      // Dark text
  static const Color textSecondary = Color(0xFF7F8C8D);    // Muted text
  static const Color shadowLight = Color(0xFFFFFFFF);      // Light shadow
  static const Color shadowDark = Color(0xFFD1D9E6);       // Dark shadow

  // Neumorphic decoration
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

  static BoxDecoration neumorphicPill({bool selected = false, Color? color}) => BoxDecoration(
    color: selected ? (color ?? primaryMint) : cardWhite,
    borderRadius: BorderRadius.circular(25),
    boxShadow: selected ? null : [
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
        seedColor: primaryMint,
        brightness: Brightness.light,
        primary: primaryMint,
        secondary: primaryOrange,
        surface: cardWhite,
        surfaceContainerHighest: bgLight,
      ),
      textTheme: _textTheme,
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
        backgroundColor: primaryMint,
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
          backgroundColor: primaryOrange,
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
        selectedColor: primaryMint,
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

  /// Dark theme (simplified - same as light for now with dark colors)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMint,
        brightness: Brightness.dark,
        primary: primaryMint,
        secondary: primaryOrange,
        surface: const Color(0xFF2A2A2A),
      ),
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }

  // ============ CUPERTINO THEME ============
  
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryMint,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: bgLight,
      scaffoldBackgroundColor: bgLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryMint,
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
