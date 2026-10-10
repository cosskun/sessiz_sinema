import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';

/// Frosted glass aesthetic card container with backdrop blur and subtle border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double blur;
  final double borderOpacity;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.blur = 15.0,
    this.borderOpacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(24.0);

    // Automatically adjust background opacity for dark/light mode if no explicit color is set
    final isDark = AppThemeManager.instance.isDarkMode;
    final defaultColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.35);
    final cardColor = color ?? defaultColor;
    final dynamicBorderOpacity = isDark ? 0.08 : borderOpacity;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 20.0,
            spreadRadius: -4.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: defaultBorderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(dynamicBorderOpacity),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
