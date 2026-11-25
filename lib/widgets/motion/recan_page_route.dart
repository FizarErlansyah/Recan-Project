import 'package:flutter/material.dart';

/// The app's page transition: a fade with a few pixels of travel along `axis`,
/// which reads as arriving without the weight of a full slide. Reduced-motion
/// users get a plain fade.
class RecanPageRoute<T> extends PageRouteBuilder<T> {
  new({required Widget page, Axis axis = Axis.vertical, super.settings})
    : super(
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, _, child) =>
            _transition(context, animation, axis, child),
      );

  static Widget _transition(
    BuildContext context,
    Animation<double> animation,
    Axis axis,
    Widget child,
  ) {
    final eased = CurveTween(curve: Curves.easeOutCubic).animate(animation);
    final faded = FadeTransition(opacity: eased, child: child);
    if (MediaQuery.disableAnimationsOf(context)) return faded;
    final start = axis == Axis.vertical
        ? const Offset(0, 0.03)
        : const Offset(0.06, 0);
    return SlideTransition(
      position: Tween<Offset>(begin: start, end: Offset.zero).animate(eased),
      child: faded,
    );
  }
}
