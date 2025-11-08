import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'agent_orb.dart';

/// Floating voice button with orb animation
class VoiceOrbButton extends StatelessWidget {
  final AgentOrbState state;
  final VoidCallback? onPressed;
  final double size;

  const VoiceOrbButton({
    super.key,
    required this.state,
    this.onPressed,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppTheme.spacingXXL,
      left: 0,
      right: 0,
      child: Center(
        child: AgentOrb(state: state, size: size, onTap: onPressed),
      ),
    );
  }
}
