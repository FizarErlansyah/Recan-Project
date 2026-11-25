import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/redeem_confirm.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/owned_voucher_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/partner_list.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_emblem.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_sections.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/points_badge.dart';
import 'package:mobile_apps_recan/widgets/single_flight.dart';

/// Everything to know before spending points: where, until when, on which
/// terms and how.
class VoucherDetailPage extends StatelessWidget {
  const new({
    required this.voucher,
    required this.balance,
    required this.onLogout,
    super.key,
  });

  static void open(
    BuildContext context, {
    required Voucher voucher,
    required int balance,
    required VoidCallback onLogout,
  }) {
    Navigator.of(context).push(
      RecanPageRoute<void>(
        page: VoucherDetailPage(
          voucher: voucher,
          balance: balance,
          onLogout: onLogout,
        ),
      ),
    );
  }

  final Voucher voucher;
  final int balance;
  final VoidCallback onLogout;

  Future<void> _redeem(BuildContext context) async {
    final String reference;
    try {
      reference = await TransactionService.redeemVoucher(voucher);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      if (error.unauthorized) {
        onLogout();
        return;
      }
      AppSnackBar.show(context, error.message);
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    HomeNavigation.goTo(0);
    if (!context.mounted) return;
    CheckoutSuccessPage.show(
      context,
      productName: voucher.title,
      receipt: PurchaseReceipt(
        reference: reference,
        pointsUsed: voucher.pointsCost,
        cashPaid: 0,
      ),
      replaceCurrent: true,
      followUp: ReceiptAction(
        label: tr('Cara Pakai', 'How to Use'),
        onPressed: (receiptContext) => unawaited(
          OwnedVoucherPage.openByReference(receiptContext, reference),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Detail Voucher', 'Voucher Details'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          _Summary(voucher: voucher),
          StaggeredEntrance(
            index: 1,
            child: PartnerList(partners: voucher.partners),
          ),
          StaggeredEntrance(
            index: 2,
            child: VoucherTerms(terms: voucher.terms),
          ),
          const StaggeredEntrance(index: 3, child: VoucherSteps()),
        ],
      ),
      bottomNavigationBar: SingleFlight(
        confirm: () => RedeemConfirm.show(
          context,
          itemName: voucher.title,
          cost: voucher.pointsCost,
          balance: balance,
        ),
        action: () => _redeem(context),
        builder: (_, redeem) => _RedeemBar(
          cost: voucher.pointsCost,
          balance: balance,
          onRedeem: redeem,
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.voucher});

  final Voucher voucher;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = voucher.validityDays;

    return Column(
      children: [
        Hero(
          tag: VoucherEmblem.heroTag(voucher),
          child: VoucherEmblem(voucher: voucher, size: 88),
        ),
        const SizedBox(height: 16),
        Text(
          voucher.title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          voucher.description,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        PointsBadge(points: voucher.pointsCost),
        const SizedBox(height: 8),
        Text(
          tr(
            'Berlaku $days hari sejak ditukar',
            'Valid for $days days after redeeming',
          ),
          textAlign: TextAlign.center,
          style: textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _RedeemBar extends StatelessWidget {
  const new({
    required this.cost,
    required this.balance,
    required this.onRedeem,
  });

  final int cost;
  final int balance;

  /// Null while a redemption is on its way.
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr(
              'Saldo kamu ${formatPoints(balance)}',
              'Your balance: ${formatPoints(balance)}',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _RedeemButton(affordable: balance >= cost, onRedeem: onRedeem),
        ],
      ),
    );
  }
}

class _RedeemButton extends StatelessWidget {
  const new({required this.affordable, required this.onRedeem});

  final bool affordable;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    // A short balance looks inactive but still answers the tap with the reason.
    final muted = FilledButton.styleFrom(
      backgroundColor: context.palette.surfaceMuted,
      foregroundColor: context.palette.textSecondary,
    );

    return FilledButton(
      onPressed: onRedeem,
      style: affordable ? null : muted,
      child: onRedeem == null ? const _Busy() : Text(tr('Tukar', 'Redeem')),
    );
  }
}

class _Busy extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.palette.textSecondary,
      ),
    );
  }
}
