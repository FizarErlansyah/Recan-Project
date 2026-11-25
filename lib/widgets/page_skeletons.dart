import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';

class CatalogSkeleton extends StatelessWidget {
  const new({super.key});

  static const int _placeholderCount = 6;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: ProductCard.height,
        ),
        itemCount: _placeholderCount,
        itemBuilder: (_, _) => const ShimmerBox(height: ProductCard.height),
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
            ShimmerBox(width: 88, height: 88, radius: 44),
            SizedBox(height: 16),
            ShimmerBox(width: 160, height: 18),
            SizedBox(height: 8),
            ShimmerBox(width: 200, height: 12),
            SizedBox(height: 24),
            ShimmerBox(height: 152),
            SizedBox(height: 32),
            ShimmerBox(height: 280),
          ],
        ),
      ),
    );
  }
}
