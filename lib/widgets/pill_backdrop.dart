import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class PillBackdrop extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDeep],
        ),
      ),
      child: SizedBox.expand(child: CustomPaint(painter: _PillPainter())),
    );
  }
}

class _PillPainter extends CustomPainter {
  const new();

  static const double _tilt = -math.pi / 4;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    _drawPill(
      canvas,
      center: Offset(width * 0.12, height * 0.1),
      length: width * 1.1,
      thickness: width * 0.42,
      color: AppColors.sage.withValues(alpha: 0.28),
    );
    _drawPill(
      canvas,
      center: Offset(width * 0.95, height * 0.3),
      length: width * 0.8,
      thickness: width * 0.3,
      color: AppColors.sage.withValues(alpha: 0.18),
    );
    _drawPill(
      canvas,
      center: Offset(width * 0.2, height * 0.55),
      length: width * 0.9,
      thickness: width * 0.34,
      color: AppColors.white.withValues(alpha: 0.06),
    );
    _drawPill(
      canvas,
      center: Offset(width * 0.9, height * 0.85),
      length: width * 0.9,
      thickness: width * 0.36,
      color: AppColors.sage.withValues(alpha: 0.2),
    );

    final linePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final lineSpan = height * 0.22;
    for (final anchor in [
      Offset(width * 0.05, height * 0.2),
      Offset(width * 0.75, height * 0.08),
      Offset(width * 0.55, height * 0.5),
    ]) {
      canvas.drawLine(
        anchor,
        anchor + Offset(lineSpan * 0.8, -lineSpan),
        linePaint,
      );
    }
  }

  void _drawPill(
    Canvas canvas, {
    required Offset center,
    required double length,
    required double thickness,
    required Color color,
  }) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(_tilt);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: length, height: thickness),
      Radius.circular(thickness / 2),
    );
    canvas
      ..drawRRect(rect, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _PillPainter oldDelegate) => false;
}
