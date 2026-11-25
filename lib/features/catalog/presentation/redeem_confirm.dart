import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// Last stop before points leave the balance: vouchers and e-wallet balance
/// cannot be taken back, so a stray tap must not spend them.
abstract final class RedeemConfirm {
  /// True only when the buyer can afford the item and approved the spend.
  static Future<bool> show(
    BuildContext context, {
    required String itemName,
    required int cost,
    required int balance,
  }) async {
    if (balance < cost) {
      AppSnackBar.show(
        context,
        tr('Poin kamu tidak cukup.', 'You do not have enough points.'),
      );
      return false;
    }
    final approved = await showDialog<bool>(
      context: context,
      builder: (_) => _RedeemDialog(
        itemName: itemName,
        cost: cost,
        remaining: balance - cost,
      ),
    );
    return approved ?? false;
  }
}

class _RedeemDialog extends StatelessWidget {
  const new({
    required this.itemName,
    required this.cost,
    required this.remaining,
  });

  final String itemName;
  final int cost;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        tr('Tukar $itemName?', 'Redeem $itemName?'),
        style: textTheme.titleLarge,
      ),
      content: Text(
        tr(
          '${formatPoints(cost)} akan dipotong dari saldo. '
              'Sisa poin: ${formatPoints(remaining)}.',
          '${formatPoints(cost)} will be taken from your balance. '
              'Points left: ${formatPoints(remaining)}.',
        ),
        style: textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('Batal', 'Cancel')),
        ),
        FilledButton(
          key: const ValueKey('redeem-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(tr('Ya, Tukar', 'Yes, Redeem')),
        ),
      ],
    );
  }
}
