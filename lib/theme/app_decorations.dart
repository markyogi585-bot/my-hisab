import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration cardDecoration({
    Color? color,
    Gradient? gradient,
    Border? border,
    double borderRadius = 18.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? AppColors.surfaceCard) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
      boxShadow: shadows ?? AppColors.cardShadow,
    );
  }

  static BoxDecoration glassCardDecoration({
    double borderRadius = 18.0,
    Color? tint,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (tint ?? AppColors.surfaceCard).withOpacity(0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.border.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    TextStyle? prefixStyle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      filled: true,
      fillColor: AppColors.surfaceElevated.withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
      ),
    );
  }
}
