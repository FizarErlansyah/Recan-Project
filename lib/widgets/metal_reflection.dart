import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// The light on a metal card: a soft diagonal band, two specular hairlines
/// beside it and a lit top edge. Every metal surface shares it, so they read
/// as one family.
class MetalReflectionPainter extends CustomPainter {
  const new({required this.band, required this.line, required this.edge});

  /// On the navy of the tier and promo cards.
  new onNavy()
    : this(
        band: AppColors.primarySoft.withValues(alpha: 0.09),
        line: AppColors.silverLight.withValues(alpha: 0.26),
        edge: AppColors.primarySoft.withValues(alpha: 0.45),
      );

  /// The strongest light of the soft band.
  final Color band;

  /// The brighter hairline. The second one is fainter.
  final Color line;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final span = size.longestSide * 2;
    final soft = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.3,
      height: span,
    );

    canvas
      ..save()
      ..translate(size.width * 0.72, size.height * 0.5)
      ..rotate(0.38)
      ..drawRect(soft, Paint()..shader = _across(band).createShader(soft));
    _hairline(canvas, size.width * 0.045, span, line);
    _hairline(
      canvas,
      size.width * 0.085,
      span,
      line.withValues(alpha: line.a * 0.46),
    );
    canvas.restore();

    final top = Rect.fromLTWH(0, 0, size.width, 1);
    canvas.drawRect(top, Paint()..shader = _across(edge).createShader(top));
  }

  // The ends keep the hue: fading to transparent black would grey the metal.
  static LinearGradient _across(Color colour) => LinearGradient(
    colors: [colour.withValues(alpha: 0), colour, colour.withValues(alpha: 0)],
  );

  // Hairlines fade out below the card's midline so they never cut through the
  // metric labels at the bottom.
  static void _hairline(Canvas canvas, double x, double span, Color colour) {
    final rect = Rect.fromLTWH(x, -span / 2, 1, span);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colour, colour, colour.withValues(alpha: 0)],
          stops: const [0, 0.47, 0.54],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(MetalReflectionPainter oldDelegate) =>
      oldDelegate.band != band ||
      oldDelegate.line != line ||
      oldDelegate.edge != edge;
}
