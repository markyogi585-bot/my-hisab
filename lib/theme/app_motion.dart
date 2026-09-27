import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  // Standard Fintech Durations
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 380);

  // Standard Easing Curves
  static const Curve easeDefault = Curves.easeInOutCubic;
  static const Curve easeOut = Curves.easeOutQuart;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve bounceSubtle = Curves.easeOutBack;

  // Reusable Micro-Interaction: Tap Bounce Scale
  static Widget scaleOnPress({
    required Widget child,
    required VoidCallback? onTap,
    double pressedScale = 0.96,
  }) {
    return _ScalePressWidget(
      onTap: onTap,
      pressedScale: pressedScale,
      child: child,
    );
  }
}

class _ScalePressWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const _ScalePressWidget({
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
  });

  @override
  State<_ScalePressWidget> createState() => _ScalePressWidgetState();
}

class _ScalePressWidgetState extends State<_ScalePressWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}
