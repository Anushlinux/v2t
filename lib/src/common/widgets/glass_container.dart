import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glassmorphism container widget with backdrop blur effect
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = AppTheme.glassBorderRadius,
    this.blur = AppTheme.glassBlur,
    this.opacity = AppTheme.glassOpacity,
    this.borderColor,
    this.borderWidth = AppTheme.glassBorderWidth,
    this.padding,
    this.margin,
    this.gradient,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              Colors.white.withOpacity(AppTheme.glassBorderOpacity),
          width: borderWidth,
        ),
        boxShadow: shadows ?? AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.5),
                    ],
                  ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
