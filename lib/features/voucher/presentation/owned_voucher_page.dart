import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/voucher/data/voucher_service.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/partner_list.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/swipe_to_confirm.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_pass.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_sections.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';

/// One voucher in the wallet, ready to show at the counter.
class OwnedVoucherPage extends StatefulWidget {
  const new({required this.owned, super.key});

  static void open(BuildContext context, OwnedVoucher owned) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: OwnedVoucherPage(owned: owned)));
  }

  static Future<void> openByReference(
    BuildContext context,
    String reference,
  ) async {
    try {
      final wallet = await VoucherService.owned();
      final match = wallet.where((owned) => owned.reference == reference);
      if (!context.mounted) return;
      if (match.isEmpty) {
        AppSnackBar.show(
          context,
          tr('Voucher tidak ditemukan.', 'Voucher not found.'),
        );
        return;
      }
      open(context, match.first);
    } on ApiException catch (error) {
      if (context.mounted) AppSnackBar.show(context, error.message);
    }
  }

  final OwnedVoucher owned;

  @override
  State<OwnedVoucherPage> createState() => _OwnedVoucherPageState();
}

class _OwnedVoucherPageState extends State<OwnedVoucherPage> {
  late OwnedVoucher _owned = widget.owned;

  Future<bool> _use() async {
    try {
      await VoucherService.use(_owned.reference);
    } on ApiException catch (error) {
      if (mounted) AppSnackBar.show(context, error.message);
      return false;
    }
    unawaited(HapticFeedback.heavyImpact());
    if (mounted) {
      setState(() => _owned = _owned.markedUsed(DateTime.now()));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final status = _owned.statusAt(DateTime.now());
    final voucher = _owned.voucher;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Voucher Saya', 'My Voucher'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            voucher.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          VoucherPass(owned: _owned, status: status),
          PartnerList(partners: voucher.partners),
          const VoucherSteps(),
          VoucherTerms(terms: voucher.terms),
        ],
      ),
      bottomNavigationBar: status == VoucherStatus.active
          ? _UseBar(onConfirmed: _use)
          : null,
    );
  }
}

class _UseBar extends StatelessWidget {
  const new({required this.onConfirmed});

  final Future<bool> Function() onConfirmed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwipeToConfirm(
              label: tr('Geser untuk tandai dipakai', 'Swipe to mark as used'),
              onConfirmed: onConfirmed,
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Geser hanya di depan kasir. Tidak bisa dibatalkan.',
                'Swipe only in front of the cashier. This cannot be undone.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.palette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
