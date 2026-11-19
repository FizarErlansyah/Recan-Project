import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/product_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/ewallet_catalog_view.dart';
import 'package:mobile_apps_recan/widgets/filter_chip_row.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';
import 'package:mobile_apps_recan/widgets/voucher_catalog_view.dart';

class KatalogPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Katalog', 'Catalog'),
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(
                      'Tukar poinmu dengan kriya, saldo e-wallet, atau voucher',
                      'Redeem your points for crafts, e-wallet balance, or '
                          'vouchers',
                    ),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SegmentedTabBar(
              labels: [
                tr('Kriya ReCan', 'ReCan Crafts'),
                'E-Wallet',
                tr('Voucher Diskon', 'Vouchers'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _CraftTab(onLogout: onLogout),
                  EWalletCatalogView(onLogout: onLogout),
                  VoucherCatalogView(onLogout: onLogout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CraftTab extends StatefulWidget {
  const new({required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<_CraftTab> createState() => _CraftTabState();
}

class _CraftTabState extends State<_CraftTab> {
  int _selectedIndex = 0;

  List<UpcycleProduct> _filter(List<UpcycleProduct> products) {
    if (_selectedIndex == 0) return products;
    final category = ProductCategory.values[_selectedIndex - 1];
    return products.where((product) => product.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      tr('Semua', 'All'),
      tr('Mainan', 'Toys'),
      tr('Hiasan', 'Decor'),
    ];

    return AsyncView<List<UpcycleProduct>>(
      loader: ProductService.fetch,
      loading: const CatalogSkeleton(),
      onUnauthorized: widget.onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, products, reload) {
        if (products.isEmpty) {
          return EmptyState(
            icon: hugeIcon(HugeIcons.strokeRoundedShoppingBag01),
            title: tr('Belum ada produk', 'No products yet'),
            message: tr(
              'Produk daur ulang akan segera tersedia.',
              'Recycled products will be available soon.',
            ),
          );
        }
        final visible = _filter(products);
        return Column(
          children: [
            FilterChipRow(
              labels: labels,
              selectedIndex: _selectedIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: reload,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: ProductCard.heightOf(context),
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final product = visible[index];
                    return ProductCard(
                      product: product,
                      fillWidth: true,
                      onTap: () => ProductDetailPage.open(context, product),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
