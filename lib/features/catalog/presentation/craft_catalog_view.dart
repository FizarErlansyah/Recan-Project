import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/product_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/sliding_segments.dart';

/// The craft tab: a sliding category filter over a two-column grid.
class CraftCatalogView extends StatefulWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  @override
  State<CraftCatalogView> createState() => _CraftCatalogViewState();
}

class _CraftCatalogViewState extends State<CraftCatalogView> {
  int _selectedIndex = 0;

  List<UpcycleProduct> _filter(List<UpcycleProduct> products) {
    if (_selectedIndex == 0) return products;
    final category = ProductCategory.values[_selectedIndex - 1];
    return products.where((product) => product.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        return Column(
          children: [
            _CategoryFilter(
              selectedIndex: _selectedIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _FilterSwitcher(
                child: _Grid(
                  key: ValueKey(_selectedIndex),
                  products: _filter(products),
                  onRefresh: reload,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const new({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SlidingSegments(
        labels: [
          tr('Semua', 'All'),
          for (final category in ProductCategory.values) category.label,
        ],
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      ),
    );
  }
}

/// Fades one filtered grid into the next.
class _FilterSwitcher extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  // The outgoing grid holds the same hero tags as the incoming one, so it sits
  // out any route transition.
  static Widget _stack(Widget? current, List<Widget> previous) => Stack(
    children: [
      for (final old in previous)
        HeroMode(key: old.key, enabled: false, child: old),
      if (current != null) HeroMode(key: current.key, child: current),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: still ? Duration.zero : const Duration(milliseconds: 220),
      layoutBuilder: _stack,
      child: child,
    );
  }
}

class _Grid extends StatelessWidget {
  const new({required this.products, required this.onRefresh, super.key});

  static const double _side = 24;
  static const double _gap = 12;

  final List<UpcycleProduct> products;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.palette.accent,
      backgroundColor: context.palette.surface,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = (constraints.maxWidth - _side * 2 - _gap) / 2;
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              _side,
              0,
              _side,
              MediaQuery.paddingOf(context).bottom + _side,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: _gap,
              crossAxisSpacing: _gap,
              mainAxisExtent: ProductCard.heightOf(context, cell),
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                fillWidth: true,
                onTap: () => ProductDetailPage.open(context, product),
              );
            },
          );
        },
      ),
    );
  }
}
