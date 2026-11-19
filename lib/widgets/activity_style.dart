import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

extension ActivityStyle on ActivityTransaction {
  bool get isDeposit => type == ActivityType.deposit;

  String get typeLabel => isDeposit
      ? tr('Setoran Kaleng', 'Can Deposit')
      : tr('Penukaran Produk', 'Product Redemption');

  AppIconBuilder get icon => isDeposit
      ? hugeIcon(HugeIcons.strokeRoundedRecycle01)
      : hugeIcon(HugeIcons.strokeRoundedShoppingBag01);

  String get locationLabel => isDeposit
      ? tr('Drop Station UPJ', 'UPJ Drop Station')
      : tr('Katalog ReCan', 'ReCan Catalog');

  String get statusLabel => tr('Berhasil', 'Success');

  Color amountColor(BuildContext context) =>
      isIncome ? context.palette.accent : context.palette.danger;

  String get amountLabel {
    final sign = isIncome ? '+' : '-';
    return '$sign${PointsHeader.formatNumber(points.abs())} '
        '${tr('Poin', 'Points')}';
  }
}

class ActivityIconBadge extends StatelessWidget {
  const new({required this.transaction, super.key, this.size = 44});

  final ActivityTransaction transaction;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: transaction.isDeposit
            ? context.palette.tint
            : context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: transaction.icon(
        // Deposits read as brand emerald; redemptions as neutral aluminium so
        // a spend never competes visually with an earn.
        color: transaction.isDeposit
            ? context.palette.accent
            : (context.isDark
                  ? context.palette.textSecondary
                  : AppColors.slate),
        size: (size * 0.5).clamp(22, 24),
      ),
    );
  }
}
