import 'package:flutter/material.dart';

/// Custom page route with fade + slide transitions
class ElevenLabsPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ElevenLabsPageRoute({required this.page, super.settings})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              // Fade transition
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

              // Slide transition
              final slideAnimation =
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      );
}
