import 'package:flutter/material.dart';

/// Gradient utilities for WebAudit Pro styling
class AppGradients {
  // Subtle gradient for section headers
  static LinearGradient subtleHeaderGradient(Color primaryColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.5),
      ],
    );
  }

  // Card gradient for visual depth
  static LinearGradient cardGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              const Color(0xFF242C3E).withOpacity(0.9),
              const Color(0xFF1A1F2E).withOpacity(0.8),
            ]
          : [
              const Color(0xFFFFFFFF).withOpacity(0.95),
              const Color(0xFFFAF9F8).withOpacity(0.9),
            ],
    );
  }

  // Score gradient - green for excellent
  static LinearGradient scoreGradientGreen() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.green.withOpacity(0.15),
        Colors.green.withOpacity(0.08),
      ],
    );
  }

  // Score gradient - orange for good
  static LinearGradient scoreGradientOrange() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.orange.withOpacity(0.15),
        Colors.orange.withOpacity(0.08),
      ],
    );
  }

  // Score gradient - red for needs improvement
  static LinearGradient scoreGradientRed() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.red.withOpacity(0.15),
        Colors.red.withOpacity(0.08),
      ],
    );
  }

  // Accent gradient for buttons
  static LinearGradient accentGradient(Color primaryColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.85),
      ],
    );
  }

  // Get appropriate score gradient based on score value
  static LinearGradient getScoreGradient(double score) {
    if (score >= 75) return scoreGradientGreen();
    if (score >= 50) return scoreGradientOrange();
    return scoreGradientRed();
  }
}
