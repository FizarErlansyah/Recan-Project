import 'package:flutter/material.dart';

/// Pushed pages fade in while rising a few pixels, which reads as arriving
/// from below without the weight of a full slide. Reduced-motion users get a
/// plain fade.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  new({required Widget page})
    : super(
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: _buildTransition,
      );

  static const Offset _rise = Offset(0, 0.03);

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final eased = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );
    final faded = FadeTransition(opacity: eased, child: child);
    if (MediaQuery.disableAnimationsOf(context)) return faded;
    return SlideTransition(
      position: Tween<Offset>(begin: _rise, end: Offset.zero).animate(eased),
      child: faded,
    );
  }
}
