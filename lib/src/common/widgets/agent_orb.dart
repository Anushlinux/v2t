import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Agent orb states
enum AgentOrbState { idle, listening, talking }

/// Animated agent orb widget with state-based visualizations
class AgentOrb extends StatefulWidget {
  final AgentOrbState state;
  final double size;
  final VoidCallback? onTap;

  const AgentOrb({
    super.key,
    required this.state,
    this.size = 120.0,
    this.onTap,
  });

  @override
  State<AgentOrb> createState() => _AgentOrbState();
}

class _AgentOrbState extends State<AgentOrb> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _colorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = AppTheme.textSecondary;

  @override
  void initState() {
    super.initState();

    // Pulse animation for listening/talking states
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ripple animation for state changes
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rippleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Color transition animation
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _currentColor = _getStateColor();
    _updateColorAnimation();
  }

  void _updateColorAnimation() {
    final targetColor = _getStateColor();

    switch (widget.state) {
      case AgentOrbState.idle:
        _pulseController.stop();
        break;
      case AgentOrbState.listening:
        _pulseController.repeat(reverse: true);
        _rippleController.forward(from: 0.0);
        break;
      case AgentOrbState.talking:
        _pulseController.repeat(reverse: true);
        _rippleController.forward(from: 0.0);
        break;
    }

    _colorAnimation = ColorTween(begin: _currentColor, end: targetColor)
        .animate(
          CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
        );

    _colorController.forward(from: 0.0);
    _currentColor = targetColor;
  }

  @override
  void didUpdateWidget(AgentOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateColorAnimation();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Color _getStateColor() {
    switch (widget.state) {
      case AgentOrbState.idle:
        return AppTheme.textSecondary;
      case AgentOrbState.listening:
        return AppTheme.accentPrimary;
      case AgentOrbState.talking:
        return AppTheme.accentSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor();
    final isActive = widget.state != AgentOrbState.idle;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _rippleAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          final orbColor = _colorAnimation.value ?? stateColor;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect
              if (isActive)
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: widget.size * _rippleAnimation.value,
                      height: widget.size * _rippleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: orbColor.withOpacity(
                          0.2 * (1 - _rippleAnimation.value / 2),
                        ),
                      ),
                    );
                  },
                ),

              // Main orb
              Container(
                width: widget.size * (isActive ? _pulseAnimation.value : 1.0),
                height: widget.size * (isActive ? _pulseAnimation.value : 1.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [orbColor, orbColor.withOpacity(0.7)],
                    stops: const [0.0, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: orbColor.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    ...AppTheme.softShadow,
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          _getStateIcon(),
                          color: AppTheme.textPrimary,
                          size: widget.size * 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getStateIcon() {
    switch (widget.state) {
      case AgentOrbState.idle:
        return Icons.mic_none;
      case AgentOrbState.listening:
        return Icons.mic;
      case AgentOrbState.talking:
        return Icons.volume_up;
    }
  }
}
