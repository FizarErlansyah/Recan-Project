import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_palette.dart';

class CircularGauge extends StatelessWidget {
  const new({
    required this.percent,
    required this.color,
    super.key,
    this.size = 36,
    this.strokeWidth = 3.5,
  });

  final int percent;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percent / 100),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: color.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Padding(
              padding: EdgeInsets.all(strokeWidth + 1),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.palette.textPrimary),
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
