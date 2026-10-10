import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A modern, spring-animated button with smooth glassmorphism and tactile tap feedback.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final List<Color>? gradientColors;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.gradientColors,
    this.icon,
    this.fullWidth = true,
    this.height = 56.0,
    this.fontSize = 16.0,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primary;
    final textCol = widget.textColor ?? Colors.white;
    final isEnabled = widget.onPressed != null;

    Widget buttonBody = Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: isEnabled
            ? (widget.gradientColors == null ? buttonColor : null)
            : Colors.grey.withOpacity(0.2),
        gradient: isEnabled && widget.gradientColors != null
            ? LinearGradient(
                colors: widget.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (widget.gradientColors?.first ?? buttonColor).withOpacity(0.3),
                  blurRadius: 12.0,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textCol, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: isEnabled ? textCol : Colors.grey.shade500,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      buttonBody = SizedBox(
        width: double.infinity,
        child: buttonBody,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: buttonBody,
      ),
    );
  }
}
