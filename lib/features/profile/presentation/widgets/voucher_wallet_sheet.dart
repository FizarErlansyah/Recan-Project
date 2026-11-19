import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/voucher_service.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class VoucherWalletSheet extends StatelessWidget {
  const new({required this.vouchers, super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoucherWalletSheet(vouchers: VoucherService.owned()),
    );
  }

  final List<OwnedVoucher> vouchers;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Voucher Saya', 'My Vouchers'),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (vouchers.isEmpty)
                const _EmptyWallet()
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: vouchers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _OwnedVoucherRow(owned: vouchers[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWallet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        tr(
          'Belum ada voucher aktif. Tukar poinmu di tab Katalog.',
          'No active vouchers yet. Redeem your points in the Catalog tab.',
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _OwnedVoucherRow extends StatelessWidget {
  const new({required this.owned});

  final OwnedVoucher owned;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final voucher = owned.voucher;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card(context),
      child: Row(
        children: [
          _VoucherIcon(voucher: voucher),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(voucher.title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${tr('Kode', 'Code')} ${owned.reference}',
                  style: textTheme.labelSmall?.copyWith(
                    color: context.palette.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  IndonesianDate.dateTime(owned.redeemedAt),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherIcon extends StatelessWidget {
  const new({required this.voucher});

  final Voucher voucher;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: voucher.colors,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: HugeIcon(icon: voucher.icon, size: 22, color: AppColors.white),
    );
  }
}
