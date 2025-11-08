import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// High-contrast primary action button with gradient and animations
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsets? padding;
  final Gradient? gradient;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56.0,
    this.padding,
    this.gradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.glassBorderRadius),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppTheme.accentPrimary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        ...AppTheme.softShadow,
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.textPrimary,
                        ),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(widget.icon, color: AppTheme.textPrimary, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                  ],
                  Text(
                    widget.label,
                    style: AppTheme.labelLarge.copyWith(
                      color: isEnabled
                          ? AppTheme.textPrimary
                          : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
