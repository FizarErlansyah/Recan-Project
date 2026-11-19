import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const new({super.key});

  Widget _card(BuildContext context, {required double height, double? width}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ShimmerBox(width: width, height: height),
      );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, 0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 64, height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 180, height: 20),
                  SizedBox(height: 16),
                  ShimmerBox(height: 176, radius: 16),
                  SizedBox(height: 24),
                  ShimmerBox(width: 180),
                  SizedBox(height: 12),
                  ShimmerBox(height: 56),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ShimmerBox(width: 140, height: 22),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _card(context, height: 72),
                  const SizedBox(height: 8),
                  _card(context, height: 72),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ShimmerBox(width: 160, height: 22),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: ProductCard.height,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    _card(
                      context,
                      width: ProductCard.width,
                      height: ProductCard.height,
                    ),
                    const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
