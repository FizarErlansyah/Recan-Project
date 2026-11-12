import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/points_badge.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class ProductCard extends StatelessWidget {
  const new({
    required this.product,
    super.key,
    this.onTap,
    this.fillWidth = false,
  });

  static const double width = 148;
  static const double height = 208;
  static const double _imageHeight = 96;

  static const double _textBlockHeight = 64;

  static double heightOf(BuildContext context) {
    final scaledText = MediaQuery.textScalerOf(context).scale(_textBlockHeight);
    return height + (scaledText - _textBlockHeight).clamp(0, 72);
  }

  static String heroTag(UpcycleProduct product) => 'product-${product.id}';

  final UpcycleProduct product;
  final VoidCallback? onTap;
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: fillWidth ? double.infinity : width,
      height: heightOf(context),
      child: ReCanCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag(product),
                    child: CoverImage(url: product.imageUrl),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _StockTag(stock: product.stock),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    const Spacer(),
                    PointsBadge(points: product.pricePoints),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        'atau Rp ${PointsHeader.formatNumber(product.priceIdr)}',
                        'or Rp ${PointsHeader.formatNumber(product.priceIdr)}',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockTag extends StatelessWidget {
  const new({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final soldOut = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: soldOut ? AppColors.danger : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        soldOut ? tr('Habis', 'Sold out') : tr('Stok $stock', 'Stock $stock'),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: soldOut ? AppColors.white : AppColors.primary),
      ),
    );
  }
}
