import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

/// Glassmorphism text field with animated focus states
class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;

  const GlassTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassContainer(
            padding: EdgeInsets.zero,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              validator: widget.validator,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                helperText: widget.helperText,
                errorText: widget.errorText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppTheme.accentPrimary
                            : AppTheme.textSecondary,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? GestureDetector(
                        onTap: widget.onSuffixTap,
                        child: Icon(
                          widget.suffixIcon,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingM,
                ),
                labelStyle: AppTheme.bodyMedium.copyWith(
                  color: _isFocused
                      ? AppTheme.accentPrimary
                      : AppTheme.textSecondary,
                ),
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
