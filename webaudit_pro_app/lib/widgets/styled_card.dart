import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/spacing.dart';

/// Custom card widget with consistent styling and elevation hierarchy
class StyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const StyledCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.large);
    final effectiveElevation = elevation ?? AppElevation.standard;
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);

    return Material(
      elevation: effectiveElevation,
      borderRadius: effectiveRadius,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.1),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Elevated card for important interactive content
class ElevatedStyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ElevatedStyledCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      elevation: AppElevation.elevated,
      padding: padding,
      backgroundColor: backgroundColor,
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: child,
    );
  }
}

/// Subtle card for secondary content with glassmorphism effect
class SubtleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const SubtleCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.large);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        elevation: AppElevation.standard,
        borderRadius: borderRadius,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.15),
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.7),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
