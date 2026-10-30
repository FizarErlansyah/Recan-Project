import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class AnimatedCheck extends StatefulWidget {
  const new({super.key, this.size = 88});

  final double size;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  late final Animation<double> _circle = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
  );
  late final Animation<double> _tick = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _CheckPainter(circle: _circle.value, tick: _tick.value),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const new({required this.circle, required this.tick});

  final double circle;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      size.width / 2 * circle.clamp(0.0, 1.2),
      Paint()..color = AppColors.primary,
    );

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.67)
      ..lineTo(size.width * 0.72, size.height * 0.36);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * tick),
      Paint()
        ..color = AppColors.primarySoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.circle != circle || oldDelegate.tick != tick;
}
