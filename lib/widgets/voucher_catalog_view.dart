import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/services/voucher_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/voucher_ticket_card.dart';

class VoucherCatalogView extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  Future<void> _redeem(BuildContext context, Voucher voucher) async {
    final String reference;
    try {
      reference = await TransactionService.redeemVoucher(voucher);
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
      productName: voucher.title,
      totalPoints: voucher.pointsCost,
      reference: reference,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<ProfileData>(
      loader: ProfileService.fetchProfile,
      loading: const CatalogSkeleton(),
      onUnauthorized: onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, profile, reload) => FutureBuilder<List<Voucher>>(
        future: VoucherService.fetch(),
        builder: (context, snapshot) {
          final vouchers = snapshot.data ?? const <Voucher>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            children: [
              Text(
                tr(
                  'Tukar poin dengan potongan harga di kampus',
                  'Trade points for campus discounts',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              for (final voucher in vouchers) ...[
                VoucherTicketCard(
                  voucher: voucher,
                  affordable: profile.points >= voucher.pointsCost,
                  onRedeem: () => _redeem(context, voucher),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}
