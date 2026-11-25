import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A short sideways nudge each time [signal] changes, used to say that a form
/// was refused without adding more words.
class Shake extends StatefulWidget {
  const new({required this.signal, required this.child, super.key});

  final int signal;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  static const double _reach = 8;
  static const int _swings = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signal == widget.signal) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        // Damped sine, so it starts and ends exactly at rest.
        final shift = math.sin(t * math.pi * 2 * _swings) * _reach * (1 - t);
        return Transform.translate(offset: Offset(shift, 0), child: child);
      },
    );
  }
}
