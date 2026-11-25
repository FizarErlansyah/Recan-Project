import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';

/// A grouped whole number whose digits roll like a counter, used for the one
/// figure a screen is about. A new value rolls on from the one shown.
class RollingNumber extends StatelessWidget {
  const new({required this.value, super.key, this.style});

  final int value;
  final TextStyle? style;

  static final RegExp _digit = RegExp(r'\d');

  @override
  Widget build(BuildContext context) {
    final text = AnimatedCountUp.format(value);
    // Proportional digits on purpose: the font's tabular ones have slab feet
    // that look like another typeface at this size.
    final figures = style ?? DefaultTextStyle.of(context).style;
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(text, style: figures);
    }

    // Keyed from the right, so the units keep rolling when a digit is added.
    final length = text.length;
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < length; i++)
            if (_digit.hasMatch(text[i]))
              _Reel(
                key: ValueKey('digit-${length - i}'),
                digit: int.parse(text[i]),
                style: figures,
              )
            else
              Text(
                text[i],
                key: ValueKey('mark-${length - i}'),
                style: figures,
              ),
        ],
      ),
    );
  }
}

class _Reel extends StatelessWidget {
  const new({required this.digit, required this.style, super.key});

  static const Duration _roll = Duration(milliseconds: 700);

  final int digit;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: digit.toDouble()),
      duration: _roll,
      curve: Curves.easeOutCubic,
      builder: (_, position, _) => _Window(position: position, style: style),
    );
  }
}

/// The slot a reel is seen through: one digit at rest, two mid-roll.
class _Window extends StatelessWidget {
  const new({required this.position, required this.style});

  final double position;
  final TextStyle style;

  Widget _face(int digit, double shift) => FractionalTranslation(
    translation: Offset(0, shift),
    child: Text('$digit', style: style),
  );

  @override
  Widget build(BuildContext context) {
    final nearest = position.round();
    if ((position - nearest).abs() < 0.01) {
      return Text('$nearest', style: style);
    }
    final lower = position.floor();
    final travel = position - lower;
    return ClipRect(
      child: Stack(
        children: [_face(lower, -travel), _face(lower + 1, 1 - travel)],
      ),
    );
  }
}
