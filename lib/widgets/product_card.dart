import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/points_badge.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// A craft in the catalog: a square photo over its name and two prices.
class ProductCard extends StatelessWidget {
  const new({
    required this.product,
    super.key,
    this.onTap,
    this.fillWidth = false,
  });

  static const double width = 148;
  static const double _textBlock = 120;

  /// Height of a [width]-wide card at the default text size.
  static const double height = width + _textBlock;

  // The text block is mostly text, but its chip and paddings do not scale, so
  // the growth is weighted; at 1.3x the plain difference clipped the price.
  static const double _growthWeight = 1.1;
  static const double _probeSize = 14;

  // Measured on body-sized text: Android 14 scales large sizes less than
  // small ones, so scaling the whole block would under-count.
  static double heightOf(BuildContext context, [double cardWidth = width]) {
    final factor =
        MediaQuery.textScalerOf(context).scale(_probeSize) / _probeSize;
    final growth = _textBlock * (factor - 1) * _growthWeight;
    return cardWidth + _textBlock + growth.clamp(0, 160);
  }

  static String heroTag(UpcycleProduct product) => 'product-${product.id}';

  final UpcycleProduct product;
  final VoidCallback? onTap;

  /// Takes the size its grid cell gives it instead of the carousel size.
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fillWidth ? double.infinity : width,
      height: fillWidth ? null : heightOf(context),
      child: ReCanCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Photo(product: product),
            Expanded(child: _Facts(product: product)),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const new({required this.product});

  final UpcycleProduct product;

  // A badge on every card would stop meaning anything.
  static const int _lowStock = 5;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroCover(product: product),
          if (product.stock <= _lowStock)
            Positioned(
              top: 8,
              left: 8,
              child: _StockBadge(stock: product.stock),
            ),
        ],
      ),
    );
  }
}

class _HeroCover extends StatelessWidget {
  const new({required this.product});

  final UpcycleProduct product;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: ProductCard.heroTag(product),
      child: CoverImage(
        url: product.imageUrl,
        seed: product.id,
        art: ProductArt.of(product.category, product.id),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const new({required this.product});

  final UpcycleProduct product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rupiah = formatRupiah(product.priceIdr);

    return Padding(
      padding: const EdgeInsets.all(12),
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
            tr('atau $rupiah', 'or $rupiah'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const new({required this.stock}) : super(key: const ValueKey('stock-badge'));

  final int stock;

  @override
  Widget build(BuildContext context) {
    final soldOut = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: soldOut ? AppColors.danger : context.palette.warm,
        shape: const StadiumBorder(),
      ),
      child: Text(
        soldOut ? tr('Habis', 'Sold out') : tr('Sisa $stock', '$stock left'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: soldOut ? AppColors.white : context.palette.onWarm,
        ),
      ),
    );
  }
}
