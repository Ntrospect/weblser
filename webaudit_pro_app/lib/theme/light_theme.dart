import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightAppTheme {
  // Light Color Palette
  static const Color bgLight = Color(0xFFF4F3F2);
  static const Color bgLighter = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF3F4F6);
  static const Color primaryAccent = Color(0xFF7c3aed); // Jumoki purple
  static const Color secondaryAccent = Color(0xFF2052b6); // Jumoki blue
  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: cardBg,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgLight,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: bgLighter,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryAccent,
          side: const BorderSide(color: primaryAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgLighter,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textSecondary,
        elevation: 1,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text Themes
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        titleLarge: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.raleway(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.raleway(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        labelMedium: GoogleFonts.raleway(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: bgLighter,
      ),
    );
  }
}
