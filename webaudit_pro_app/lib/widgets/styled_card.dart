import 'package:flutter/material.dart';
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

/// Subtle card for secondary content
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

    return Material(
      elevation: AppElevation.standard,
      borderRadius: borderRadius,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.15),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
