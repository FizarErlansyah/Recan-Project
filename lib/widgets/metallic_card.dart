import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Membership-card surface: emerald gradient, silver hairline border and a
/// faint diagonal sheen. Shared by the balance card and the tier card so both
/// read as one metal-card family.
class MetallicCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.colors = const [AppColors.primary, AppColors.primaryDark],
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.silverLight.withValues(alpha: 0.42),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: CustomPaint(
              painter: const _SheenPainter(),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final span = size.longestSide * 2;
    final band = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.3,
      height: span,
    );
    final softBand = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.transparent,
          AppColors.white.withValues(alpha: 0.07),
          AppColors.transparent,
        ],
      ).createShader(band);

    // Hairlines fade out below the card's midline so they never cut through
    // the metric labels at the bottom.
    Paint hairline(double x, double alpha) {
      final rect = Rect.fromLTWH(x, -span / 2, 1, span);
      final color = AppColors.silverLight.withValues(alpha: alpha);
      return Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color, AppColors.transparent],
          stops: const [0, 0.47, 0.54],
        ).createShader(rect);
    }

    canvas
      ..save()
      ..translate(size.width * 0.72, size.height * 0.5)
      ..rotate(0.38)
      ..drawRect(band, softBand)
      ..drawRect(
        Rect.fromLTWH(size.width * 0.045, -span / 2, 1, span),
        hairline(size.width * 0.045, 0.26),
      )
      ..drawRect(
        Rect.fromLTWH(size.width * 0.085, -span / 2, 1, span),
        hairline(size.width * 0.085, 0.12),
      )
      ..restore();

    final topEdge = Rect.fromLTWH(0, 0, size.width, 1);
    canvas.drawRect(
      topEdge,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.transparent,
            AppColors.white.withValues(alpha: 0.38),
            AppColors.transparent,
          ],
        ).createShader(topEdge),
    );
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) => false;
}
