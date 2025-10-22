import 'package:flutter/material.dart';
import 'spacing.dart';

/// Custom button styles for WebAudit Pro
class AppButtonStyles {
  // Primary button style (elevated)
  static ButtonStyle primaryElevatedButton(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      elevation: MaterialStateProperty.resolveWith<double>((states) {
        if (states.contains(MaterialState.hovered)) return 4;
        if (states.contains(MaterialState.pressed)) return 1;
        if (states.contains(MaterialState.disabled)) return 0;
        return 2;
      }),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return primaryColor.withOpacity(0.38);
        }
        if (states.contains(MaterialState.pressed)) {
          return primaryColor.withOpacity(0.85);
        }
        return primaryColor;
      }),
    );
  }

  // Secondary button style (outlined)
  static ButtonStyle secondaryOutlinedButton(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      side: MaterialStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(MaterialState.disabled)) {
          return BorderSide(
            color: primaryColor.withOpacity(0.38),
          );
        }
        if (states.contains(MaterialState.pressed)) {
          return BorderSide(color: primaryColor.withOpacity(0.85));
        }
        return BorderSide(color: primaryColor);
      }),
    );
  }

  // Text button style (minimal)
  static ButtonStyle textButton(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return TextButton.styleFrom(
      foregroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
    ).copyWith(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return primaryColor.withOpacity(0.38);
        }
        if (states.contains(MaterialState.pressed)) {
          return primaryColor.withOpacity(0.85);
        }
        return primaryColor;
      }),
    );
  }

  // Compact button (for icons with optional label)
  static ButtonStyle compactElevatedButton(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 1,
      padding: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Action button - for critical actions (e.g., delete, download)
  static ButtonStyle actionButton(
    BuildContext context, {
    bool isDangerous = false,
  }) {
    final color = isDangerous ? Colors.red : Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      elevation: MaterialStateProperty.resolveWith<double>((states) {
        if (states.contains(MaterialState.hovered)) return 4;
        if (states.contains(MaterialState.pressed)) return 1;
        if (states.contains(MaterialState.disabled)) return 0;
        return 2;
      }),
    );
  }
}
