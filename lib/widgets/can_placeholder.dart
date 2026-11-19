import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

/// Stand-in for a product photo: a brushed-aluminium can, tinted per product,
/// so catalog tiles still read as upcycled metal when no image is available.
class CanPlaceholder extends StatelessWidget {
  const new({required this.seed, super.key});

  static const List<Color> _labelTints = [
    AppColors.primary,
    AppColors.slate,
    AppColors.goldDeep,
    AppColors.sage,
  ];

  final int seed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primarySoft, context.palette.surfaceMuted],
        ),
      ),
      child: CustomPaint(
        painter: _CanPainter(_labelTints[seed.abs() % _labelTints.length]),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CanPainter extends CustomPainter {
  const new(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.shortestSide * 0.64;
    final width = height * 0.5;
    final center = Offset(size.width / 2, size.height / 2);
    final body = Rect.fromCenter(center: center, width: width, height: height);
    final bodyShape = RRect.fromRectAndRadius(
      body,
      Radius.circular(width * 0.16),
    );

    _paintGroundShadow(canvas, body, height);
    canvas
      ..drawRRect(bodyShape, _metal(body))
      ..save()
      ..clipRRect(bodyShape);
    _paintLabel(canvas, body);
    _paintHighlight(canvas, body);
    canvas.restore();
    _paintRim(canvas, body);
  }

  void _paintGroundShadow(Canvas canvas, Rect body, double height) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(body.center.dx, body.bottom + height * 0.04),
        width: body.width * 1.15,
        height: height * 0.07,
      ),
      Paint()
        ..color = AppColors.primaryDeep.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, height * 0.03),
    );
  }

  Paint _metal(Rect body) {
    return Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.silver,
          AppColors.white,
          AppColors.silverLight,
          AppColors.silver,
          AppColors.slate,
        ],
        stops: [0, 0.28, 0.55, 0.85, 1],
      ).createShader(body);
  }

  void _paintLabel(Canvas canvas, Rect body) {
    final band = Rect.fromLTRB(
      body.left,
      body.top + body.height * 0.34,
      body.right,
      body.top + body.height * 0.68,
    );
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    canvas
      ..drawRect(band, Paint()..color = tint)
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.transparent,
              AppColors.white.withValues(alpha: 0.24),
              AppColors.transparent,
            ],
          ).createShader(band),
      )
      ..drawLine(band.topLeft, band.topRight, line)
      ..drawLine(band.bottomLeft, band.bottomRight, line);
  }

  void _paintHighlight(Canvas canvas, Rect body) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          body.left + body.width * 0.16,
          body.top + body.height * 0.06,
          body.width * 0.07,
          body.height * 0.88,
        ),
        Radius.circular(body.width * 0.035),
      ),
      Paint()..color = AppColors.white.withValues(alpha: 0.38),
    );
  }

  void _paintRim(Canvas canvas, Rect body) {
    final rim = Rect.fromCenter(
      center: Offset(body.center.dx, body.top + body.width * 0.04),
      width: body.width * 0.84,
      height: body.width * 0.2,
    );
    canvas
      ..drawOval(rim, Paint()..color = AppColors.silverLight)
      ..drawOval(
        rim,
        Paint()
          ..color = AppColors.silver
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      )
      ..drawOval(
        rim.deflate(body.width * 0.07),
        Paint()..color = AppColors.slate,
      );
  }

  @override
  bool shouldRepaint(_CanPainter oldDelegate) => oldDelegate.tint != tint;
}
