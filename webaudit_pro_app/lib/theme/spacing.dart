/// Consistent spacing system for WebAudit Pro
/// Based on 16px base unit (Material Design 3 standard)
class AppSpacing {
  // Base unit: 16px (one rem equivalent)
  static const double base = 16.0;

  // Spacing scale (in multiples of 4px)
  static const double xs = 4.0;      // Extra small
  static const double sm = 8.0;      // Small
  static const double md = 16.0;     // Medium (base unit)
  static const double lg = 24.0;     // Large
  static const double xl = 32.0;     // Extra large
  static const double xxl = 48.0;    // Double extra large

  // Specific use cases
  static const double horizontal = md;        // Horizontal padding for screens
  static const double vertical = md;          // Vertical padding for screens
  static const double cardPadding = lg;       // Padding inside cards
  static const double sectionGap = lg;        // Gap between major sections
  static const double componentGap = md;      // Gap between components
  static const double itemGap = sm;           // Gap between list items
}

/// Card elevation constants for visual hierarchy
class AppElevation {
  static const double subtle = 1.0;    // Subtle cards, secondary content
  static const double standard = 2.0;  // Standard cards, main content
  static const double elevated = 4.0;  // Elevated cards, interactive/important
  static const double floating = 8.0;  // Floating action buttons, modals
}

/// Border radius constants
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 20.0;
}
