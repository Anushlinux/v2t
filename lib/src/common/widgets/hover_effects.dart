import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Hover effect wrapper with scale and glow animations
class HoverEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleAmount;
  final bool enableGlow;

  const HoverEffect({
    super.key,
    required this.child,
    this.onTap,
    this.scaleAmount = 1.05,
    this.enableGlow = false,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.enableGlow && _isHovered
                  ? Container(
                      decoration: BoxDecoration(boxShadow: AppTheme.glowShadow),
                      child: widget.child,
                    )
                  : widget.child,
            );
          },
        ),
      ),
    );
  }
}

/// Scroll effect with fade-in animations
class ScrollFadeEffect extends StatefulWidget {
  final Widget child;
  final double fadeStart;
  final double fadeEnd;

  const ScrollFadeEffect({
    super.key,
    required this.child,
    this.fadeStart = 0.0,
    this.fadeEnd = 1.0,
  });

  @override
  State<ScrollFadeEffect> createState() => _ScrollFadeEffectState();
}

class _ScrollFadeEffectState extends State<ScrollFadeEffect> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollPercentage = scrollPosition / (maxScroll + 1);

    setState(() {
      _opacity =
          widget.fadeStart +
          (widget.fadeEnd - widget.fadeStart) * (1 - scrollPercentage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _opacity, child: widget.child);
  }
}
