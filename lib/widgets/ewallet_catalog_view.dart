import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/redeem_confirm.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/ewallet_tile.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/single_flight.dart';

class EWalletCatalogView extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  Future<void> _redeem(BuildContext context, EWalletOption option) async {
    final String reference;
    try {
      reference = await TransactionService.redeemEWallet(option);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.show(context, error.message);
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    HomeNavigation.goTo(0);
    if (!context.mounted) return;
    CheckoutSuccessPage.show(
      context,
      productName: option.title,
      receipt: PurchaseReceipt(
        reference: reference,
        pointsUsed: option.pointsCost,
        cashPaid: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AsyncView<ProfileData>(
      loader: ProfileService.fetchProfile,
      loading: const CatalogSkeleton(),
      onUnauthorized: onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, profile, reload) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        children: [
          _BalanceBanner(points: profile.points),
          for (final provider in EWalletOption.providers) ...[
            const SizedBox(height: 24),
            Text(provider, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final option in EWalletOption.forProvider(provider)) ...[
              SingleFlight(
                key: ValueKey(option.titleId),
                confirm: () => RedeemConfirm.show(
                  context,
                  itemName: option.title,
                  cost: option.pointsCost,
                  balance: profile.points,
                ),
                action: () => _redeem(context, option),
                builder: (_, redeem) => EWalletTile(
                  option: option,
                  affordable: profile.points >= option.pointsCost,
                  busy: redeem == null,
                  onRedeem: redeem,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          HugeIcon(icon: AppIcons.coins, color: context.palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr('Saldo poinmu', 'Your points balance'),
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.accent,
              ),
            ),
          ),
          Text(
            tr(
              '${PointsHeader.formatNumber(points)} Poin',
              '${PointsHeader.formatNumber(points)} Points',
            ),
            style: textTheme.titleMedium?.copyWith(
              color: context.palette.accent,
            ),
          ),
        ],
      ),
    );
  }
}
