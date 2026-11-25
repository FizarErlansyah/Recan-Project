import 'package:flutter/material.dart';

/// A figure that glides to its new value when the order changes. It opens on
/// the value itself: counting up from zero would read as a price still loading.
class AnimatedAmount extends StatelessWidget {
  const new({
    required this.value,
    required this.format,
    super.key,
    this.style,
    this.textKey,
  });

  final int value;
  final String Function(int value) format;
  final TextStyle? style;

  /// Lands on the [Text] itself, for callers that need to read it.
  final Key? textKey;

  static const Duration _glide = Duration(milliseconds: 320);

  Widget _text(int shown) => Text(format(shown), key: textKey, style: style);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return _text(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value.toDouble(), end: value.toDouble()),
      duration: _glide,
      curve: Curves.easeOutCubic,
      builder: (_, shown, _) => _text(shown.round()),
    );
  }
}
