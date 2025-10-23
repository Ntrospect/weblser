import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryPurple = Color(0xFF7c3aed);
  static const Color secondaryBlue = Color(0xFF2052b6);
  static const Color charcoalText = Color(0xFF0B1220);
  static const Color offWhiteBackground = Color(0xFFF6F8FF);
  static const Color coolGray = Color(0xFFB9C2D0);
  static const Color lightGray = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryBlue,
        surface: offWhiteBackground,
        error: Colors.red[600] ?? Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: charcoalText,
      ),
      scaffoldBackgroundColor: offWhiteBackground,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: offWhiteBackground,
        foregroundColor: charcoalText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: charcoalText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: coolGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[600] ?? Colors.red),
        ),
        hintStyle: const TextStyle(
          color: coolGray,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: charcoalText,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: primaryPurple.withOpacity(0.4),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 1.5),
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

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: coolGray,
        elevation: 8,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text Themes
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: charcoalText,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          color: charcoalText,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          color: charcoalText,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          color: charcoalText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: charcoalText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: charcoalText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: charcoalText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: charcoalText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: coolGray,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          color: coolGray,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
