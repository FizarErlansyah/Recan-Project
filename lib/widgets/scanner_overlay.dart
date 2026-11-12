import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  const new({super.key});

  static const double _maxWindowSize = 280;
  static const double _radius = 16;

  static Rect windowRect(Size size) {
    final side = math.min(size.width * 0.7, _maxWindowSize);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: side,
      height: side,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(size: Size.infinite, painter: _OverlayPainter());
  }
}

class _OverlayPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final window = RRect.fromRectAndRadius(
      ScannerOverlay.windowRect(size),
      const Radius.circular(ScannerOverlay._radius),
    );
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(window);

    canvas
      ..drawPath(
        scrim,
        Paint()..color = AppColors.scrim.withValues(alpha: 0.72),
      )
      ..drawRRect(
        window,
        Paint()
          ..color = AppColors.primarySoft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) => false;
}
