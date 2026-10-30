import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class ReCanLogo extends StatelessWidget {
  const new({
    super.key,
    this.size = 72,
    this.asset = 'assets/images/recan_brandmak_aqua.png',
  });

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _BrandBadgeFallback(size: size),
      ),
    );
  }
}

class _BrandBadgeFallback extends StatelessWidget {
  const new({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.recycling_rounded,
        size: size / 2,
        color: AppColors.primary,
      ),
    );
  }
}
