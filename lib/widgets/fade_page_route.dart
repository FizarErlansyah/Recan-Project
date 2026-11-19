import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  new({required Widget page})
    : super(
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      );
}
