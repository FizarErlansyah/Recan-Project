import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/widgets/product_art_painter.dart';

/// Stand-in for a product photo: a drawing of the craft in brushed aluminium,
/// tinted per product, until a real photo is uploaded.
class CanPlaceholder extends StatelessWidget {
  const new({required this.seed, super.key, this.art = ProductArt.can});

  static const List<Color> _labelTints = [
    AppColors.primary,
    AppColors.success,
    AppColors.goldDeep,
    AppColors.primaryLight,
    AppColors.bronze,
  ];

  final int seed;
  final ProductArt art;

  @override
  Widget build(BuildContext context) {
    final tint = _labelTints[seed.abs() % _labelTints.length];
    final ground = context.palette.surfaceMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1.2,
          colors: [
            Color.alphaBlend(tint.withValues(alpha: 0.2), ground),
            ground,
          ],
        ),
      ),
      child: CustomPaint(
        painter: ProductArtPainter(art: art, label: tint),
        child: const SizedBox.expand(),
      ),
    );
  }
}
