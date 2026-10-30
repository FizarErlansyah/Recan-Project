import 'package:flutter/material.dart';

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  new({required Widget page})
    : super(
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
