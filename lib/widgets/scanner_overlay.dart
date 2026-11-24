import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  const new({super.key});

  static const double _maxWindowSize = 280;
  static const double _radius = 16;
  static const double _frameThickness = 12;

  static Rect windowRect(Size size) {
    final side = math.min(size.width * 0.7, _maxWindowSize);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: side,
      height: side,
    );
  }

  static RRect _inner(Rect window) =>
      RRect.fromRectAndRadius(window, const Radius.circular(_radius));

  static RRect _outer(Rect window) => RRect.fromRectAndRadius(
    window.inflate(_frameThickness),
    const Radius.circular(_radius + _frameThickness),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final window = windowRect(constraints.biggest);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ScrimPainter(window)),
            _FrostedFrame(window: window),
            CustomPaint(painter: _CornerPainter(window)),
          ],
        );
      },
    );
  }
}

class _FrostedFrame extends StatelessWidget {
  const new({required this.window});

  final Rect window;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RingClipper(window),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: CustomPaint(painter: _RingEdgePainter(window)),
      ),
    );
  }
}

Path _ringPath(Rect window) => Path()
  ..fillType = PathFillType.evenOdd
  ..addRRect(ScannerOverlay._outer(window))
  ..addRRect(ScannerOverlay._inner(window));

class _RingClipper extends CustomClipper<Path> {
  const new(this.window);

  final Rect window;

  @override
  Path getClip(Size size) => _ringPath(window);

  @override
  bool shouldReclip(_RingClipper oldClipper) => oldClipper.window != window;
}

class _RingEdgePainter extends CustomPainter {
  const new(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawPath(
        _ringPath(window),
        Paint()..color = AppColors.white.withValues(alpha: 0.10),
      )
      ..drawRRect(
        ScannerOverlay._outer(window),
        _hairline(AppColors.white.withValues(alpha: 0.30)),
      )
      ..drawRRect(
        ScannerOverlay._inner(window),
        _hairline(AppColors.white.withValues(alpha: 0.22)),
      );
  }

  static Paint _hairline(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  bool shouldRepaint(_RingEdgePainter oldDelegate) =>
      oldDelegate.window != window;
}

class _ScrimPainter extends CustomPainter {
  const new(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(ScannerOverlay._outer(window));

    canvas.drawPath(
      scrim,
      Paint()..color = AppColors.scrim.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter oldDelegate) => oldDelegate.window != window;
}

class _CornerPainter extends CustomPainter {
  const new(this.window);

  static const double _arm = 30;

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.primarySoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final half = window.width / 2;
    final corner = _corner(half);

    // Window is square, so four 90° turns about its center draw all corners.
    canvas
      ..save()
      ..translate(window.center.dx, window.center.dy);
    for (var i = 0; i < 4; i++) {
      canvas
        ..drawPath(corner, stroke)
        ..rotate(math.pi / 2);
    }
    canvas.restore();
  }

  Path _corner(double half) {
    const radius = ScannerOverlay._radius;
    return Path()
      ..moveTo(-half, -half + _arm)
      ..lineTo(-half, -half + radius)
      ..arcTo(
        Rect.fromLTWH(-half, -half, radius * 2, radius * 2),
        math.pi,
        math.pi / 2,
        false,
      )
      ..lineTo(-half + _arm, -half);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.window != window;
}
