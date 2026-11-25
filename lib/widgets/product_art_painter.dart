import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';

/// Brushed-aluminium silhouettes of the crafts, drawn on a 100 x 100 grid and
/// scaled to the tile. They stay recognisably "made from cans": one metal
/// gradient, one printed label colour.
class ProductArtPainter extends CustomPainter {
  const new({required this.art, required this.label});

  final ProductArt art;
  final Color label;

  static const double _grid = 100;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _grid * 0.86;
    canvas
      ..save()
      ..translate(
        (size.width - _grid * scale) / 2,
        (size.height - _grid * scale) / 2,
      )
      ..scale(scale);
    _shadow(canvas);
    switch (art) {
      case ProductArt.raceCar:
        _raceCar(canvas);
      case ProductArt.jet:
        _jet(canvas);
      case ProductArt.classicCar:
        _classicCar(canvas);
      case ProductArt.ship:
        _ship(canvas);
      case ProductArt.vase:
        _vase(canvas);
      case ProductArt.lamp:
        _lamp(canvas);
      case ProductArt.can:
        _can(canvas);
    }
    canvas.restore();
  }

  void _shadow(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(18, 82, 64, 6),
      Paint()
        ..color = AppColors.primaryDeep.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  Paint get _metal => Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.silverLight,
        AppColors.white,
        AppColors.silver,
        AppColors.slate,
      ],
      stops: [0, 0.3, 0.7, 1],
    ).createShader(const Rect.fromLTWH(0, 0, _grid, _grid));

  Paint get _paint => Paint()..color = label;

  void _wheel(Canvas canvas, double x, double y, double radius) {
    final centre = Offset(x, y);
    canvas
      ..drawCircle(centre, radius, Paint()..color = AppColors.slateDeep)
      ..drawCircle(centre, radius * 0.45, _metal);
  }

  void _polygon(Canvas canvas, List<Offset> points, Paint paint) {
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }

  void _slab(Canvas canvas, Rect rect, double radius, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  void _raceCar(Canvas canvas) {
    _slab(canvas, const Rect.fromLTWH(8, 42, 6, 24), 2, _paint);
    _polygon(canvas, const [
      Offset(10, 60),
      Offset(40, 48),
      Offset(60, 52),
      Offset(94, 66),
      Offset(94, 70),
      Offset(10, 70),
    ], _metal);
    _slab(canvas, const Rect.fromLTWH(28, 58, 40, 7), 3, _paint);
    _slab(canvas, const Rect.fromLTWH(44, 42, 12, 10), 5, _paint);
    _wheel(canvas, 27, 72, 11);
    _wheel(canvas, 74, 73, 10);
  }

  void _jet(Canvas canvas) {
    _polygon(canvas, const [
      Offset(52, 36),
      Offset(34, 70),
      Offset(58, 58),
    ], _paint);
    _polygon(canvas, const [
      Offset(8, 54),
      Offset(60, 42),
      Offset(94, 48),
      Offset(62, 58),
      Offset(16, 60),
    ], _metal);
    _polygon(canvas, const [
      Offset(10, 55),
      Offset(14, 30),
      Offset(30, 52),
    ], _paint);
    canvas.drawOval(const Rect.fromLTWH(58, 42, 18, 8), _paint);
  }

  void _classicCar(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(24, 56)
        ..quadraticBezierTo(34, 30, 54, 32)
        ..quadraticBezierTo(70, 34, 74, 56)
        ..close(),
      _paint,
    );
    _slab(canvas, const Rect.fromLTWH(34, 40, 14, 14), 3, _metal);
    _slab(canvas, const Rect.fromLTWH(52, 40, 14, 14), 3, _metal);
    _slab(canvas, const Rect.fromLTWH(10, 54, 82, 18), 9, _metal);
    _wheel(canvas, 28, 74, 10);
    _wheel(canvas, 72, 74, 10);
  }

  void _ship(Canvas canvas) {
    for (final (x, top) in [(38.0, 12.0), (60.0, 18.0)]) {
      canvas.drawRect(Rect.fromLTWH(x, top, 2, 58 - top), _metal);
      _polygon(canvas, [
        Offset(x + 3, top + 2),
        Offset(x + 20, 54),
        Offset(x + 3, 54),
      ], _paint);
      _polygon(canvas, [
        Offset(x - 1, top + 6),
        Offset(x - 18, 54),
        Offset(x - 1, 54),
      ], _metal);
    }
    final hull = Path()
      ..moveTo(6, 58)
      ..lineTo(94, 56)
      ..quadraticBezierTo(86, 80, 66, 80)
      ..lineTo(28, 80)
      ..quadraticBezierTo(14, 76, 6, 58)
      ..close();
    canvas
      ..drawPath(hull, _metal)
      ..drawRect(const Rect.fromLTWH(18, 64, 66, 5), _paint);
  }

  void _vase(Canvas canvas) {
    for (final (x, y) in [(32.0, 18.0), (52.0, 8.0), (68.0, 22.0)]) {
      canvas
        ..drawLine(
          const Offset(50, 40),
          Offset(x, y),
          Paint()
            ..color = AppColors.success
            ..strokeWidth = 2,
        )
        ..drawCircle(Offset(x, y), 7, _paint)
        ..drawCircle(Offset(x, y), 2.5, Paint()..color = AppColors.warm);
    }
    final body = Path()
      ..moveTo(40, 36)
      ..lineTo(60, 36)
      ..quadraticBezierTo(56, 46, 66, 56)
      ..quadraticBezierTo(76, 76, 62, 84)
      ..lineTo(38, 84)
      ..quadraticBezierTo(24, 76, 34, 56)
      ..quadraticBezierTo(44, 46, 40, 36)
      ..close();
    canvas
      ..drawPath(body, _metal)
      ..save()
      ..clipPath(body)
      ..drawRect(const Rect.fromLTWH(20, 62, 60, 10), _paint)
      ..restore();
  }

  void _lamp(Canvas canvas) {
    canvas.drawCircle(
      const Offset(50, 46),
      26,
      Paint()
        ..color = AppColors.warm.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    _polygon(canvas, const [
      Offset(36, 16),
      Offset(64, 16),
      Offset(78, 46),
      Offset(22, 46),
    ], _paint);
    canvas.drawRect(const Rect.fromLTWH(47, 46, 6, 28), _metal);
    _slab(canvas, const Rect.fromLTWH(30, 72, 40, 12), 5, _metal);
  }

  void _can(Canvas canvas) {
    const body = Rect.fromLTWH(32, 18, 36, 66);
    final shape = RRect.fromRectAndRadius(body, const Radius.circular(7));
    canvas
      ..drawRRect(shape, _metal)
      ..drawRect(const Rect.fromLTWH(32, 40, 36, 22), _paint)
      ..drawOval(const Rect.fromLTWH(35, 15, 30, 8), _metal)
      ..drawArc(
        const Rect.fromLTWH(43, 17, 14, 4),
        0,
        math.pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.slate,
      );
  }

  @override
  bool shouldRepaint(ProductArtPainter oldDelegate) =>
      oldDelegate.art != art || oldDelegate.label != label;
}
