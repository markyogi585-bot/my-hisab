import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../theme/app_decorations.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final double borderRadius;
  final Border? border;
  final List<BoxShadow>? shadows;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.gradient,
    this.color,
    this.borderRadius = 18.0,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: AppDecorations.cardDecoration(
        color: color,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        shadows: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primary.withOpacity(0.12),
          highlightColor: AppColors.primary.withOpacity(0.06),
          child: card,
        ),
      );
    }

    return card;
  }
}
