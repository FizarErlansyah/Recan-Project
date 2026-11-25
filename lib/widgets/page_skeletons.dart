import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';

class CatalogSkeleton extends StatelessWidget {
  const new({super.key});

  static const int _placeholderCount = 6;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The same cell the loaded grid uses, so nothing jumps.
          final cell = (constraints.maxWidth - 60) / 2;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: ProductCard.heightOf(context, cell),
            ),
            itemCount: _placeholderCount,
            itemBuilder: (_, _) => const ShimmerBox(height: double.infinity),
          );
        },
      ),
    );
  }
}

class ActivitySkeleton extends StatelessWidget {
  const new({super.key});

  static const int _placeholderCount = 6;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: _placeholderCount,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (_, _) => const Row(
          children: [
            ShimmerBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 12),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 64, height: 14),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            ShimmerBox(height: 168, radius: 20),
            SizedBox(height: 24),
            ShimmerBox(height: 164, radius: 20),
            SizedBox(height: 32),
            ShimmerBox(height: 280),
          ],
        ),
      ),
    );
  }
}
