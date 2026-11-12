import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/checkout_page.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/parallax_cover_app_bar.dart';
import 'package:mobile_apps_recan/widgets/points_badge.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';

class ProductDetailPage extends StatelessWidget {
  const new({required this.product, super.key});

  static const double _coverHeight = 350;
  static String get _upcycleStory => tr(
    'Setiap karya ReCan bermula dari kaleng minuman bekas yang dikumpulkan '
        'di Drop Station. Kaleng dibersihkan, dipotong, lalu dibentuk satu per '
        'satu oleh perajin lokal hingga berubah menjadi kerajinan bernilai seni '
        'tinggi.\n\n'
        'Tidak ada cetakan pabrik. Setiap sambungan dipoles dengan tangan, '
        'sehingga tiap karya memiliki karakter yang tidak akan sama persis. '
        'Dengan menukarkan poinmu, kamu ikut menjaga aluminium tetap berputar '
        'dalam ekonomi sirkular.',
    'Every ReCan creation starts as a used drink can collected at '
        'a Drop Station. The can is cleaned, cut, then shaped one by '
        'one by local artisans until it becomes a work of high '
        'artistic value.\n\nThere are no factory molds. Every joint '
        'is polished by hand, so each piece has a character that is '
        'never exactly the same. By redeeming your points, you help '
        'keep aluminum circulating in the circular economy.',
  );
  static List<(String, String)> get _specifications => [
    ('Material', tr('100% Aluminium Upcycle', '100% Upcycled Aluminum')),
    (
      tr('Dimensi', 'Dimensions'),
      tr('Presisi Skala 1:18', '1:18 Scale Precision'),
    ),
    (
      tr('Kondisi', 'Condition'),
      tr('Baru & Dilapisi Anti-Karat', 'New & Rust-Proof Coated'),
    ),
  ];

  static void open(BuildContext context, UpcycleProduct product) {
    Navigator.of(context)
        .push(FadePageRoute<void>(page: ProductDetailPage(product: product)));
  }

  final UpcycleProduct product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          ParallaxCoverAppBar(
            expandedHeight: _coverHeight,
            title: product.name,
            cover: Hero(
              tag: ProductCard.heroTag(product),
              child: CoverImage(url: product.imageUrl, placeholderSize: 72),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: _Details(
                product: product,
                story: ProductDetailPage._upcycleStory,
                specifications: ProductDetailPage._specifications,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _RedeemBar(
        enabled: product.stock > 0,
        onPressed: () => CheckoutPage.open(context, product),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const new({
    required this.product,
    required this.story,
    required this.specifications,
  });

  final UpcycleProduct product;
  final String story;
  final List<(String, String)> specifications;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final soldOut = product.stock <= 0;
    final stockColor = soldOut ? AppColors.danger : AppColors.textSecondary;
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: textTheme.headlineMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            PointsBadge(points: product.pricePoints),
            const SizedBox(width: 16),
            Icon(Icons.inventory_2_rounded, size: 16, color: stockColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                soldOut
                    ? tr('Stok habis', 'Out of stock')
                    : tr(
                        'Sisa stok: ${product.stock}',
                        'Stock left: ${product.stock}',
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(color: stockColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            'atau Rp ${PointsHeader.formatNumber(product.priceIdr)}',
            'or Rp ${PointsHeader.formatNumber(product.priceIdr)}',
          ),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 24),
        Text(tr('Deskripsi', 'Description'), style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(product.description, style: bodyStyle),
        const SizedBox(height: 24),
        Text(
          tr('Dari Kaleng Menjadi Karya', 'From Cans to Craft'),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(story, style: bodyStyle),
        const SizedBox(height: 24),
        Text(
          tr('Spesifikasi Produk', 'Product Specifications'),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < specifications.length; i++)
          _SpecificationRow(
            label: specifications[i].$1,
            value: specifications[i].$2,
            showDivider: i < specifications.length - 1,
          ),
      ],
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: Text(label, style: textTheme.bodySmall),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}

class _RedeemBar extends StatelessWidget {
  const new({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textSecondary,
            ),
            child: Text(
              enabled
                  ? tr('Tukar Sekarang', 'Redeem Now')
                  : tr('Stok Habis', 'Out of Stock'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: enabled ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
