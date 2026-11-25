import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

/// A whole number that climbs to its value, written with Indonesian thousands
/// separators. A new value continues from the one on screen.
class AnimatedCountUp extends StatelessWidget {
  const new({
    required this.value,
    super.key,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  static String format(int value) {
    final digits = PointsHeader.formatNumber(value.abs());
    return value < 0 ? '-$digits' : digits;
  }

  Widget _text(int shown) =>
      Text('$prefix${format(shown)}$suffix', style: style);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return _text(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, shown, _) => _text(shown.round()),
    );
  }
}
