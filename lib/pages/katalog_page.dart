import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/craft_catalog_view.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_catalog_view.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/ewallet_catalog_view.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

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
                tr('Voucher', 'Vouchers'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  CraftCatalogView(onLogout: onLogout),
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
