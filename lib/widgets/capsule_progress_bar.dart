import 'package:flutter/material.dart';

class CapsuleProgressBar extends StatelessWidget {
  const new({
    required this.value,
    required this.colors,
    required this.trackColor,
    super.key,
    this.height = 12,
  });

  final double value;
  final List<Color> colors;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: v,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(colors: colors),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
