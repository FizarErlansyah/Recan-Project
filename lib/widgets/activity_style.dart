import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

extension ActivityStyle on ActivityTransaction {
  bool get isDeposit => type == ActivityType.deposit;

  String get typeLabel => isDeposit
      ? tr('Setoran Kaleng', 'Can Deposit')
      : tr('Penukaran Produk', 'Product Redemption');

  IconData get icon =>
      isDeposit ? Icons.recycling_rounded : Icons.shopping_bag_rounded;

  Color get iconBackground => isDeposit
      ? AppColors.successSoft
      : AppColors.clay.withValues(alpha: 0.18);

  Color get iconColor => isDeposit ? AppColors.success : AppColors.clay;

  Color get badgeBackground => iconBackground;

  Color get badgeColor => iconColor;

  String get locationLabel => isDeposit
      ? tr('Drop Station UPJ', 'UPJ Drop Station')
      : tr('Katalog ReCan', 'ReCan Catalog');

  String get statusLabel => tr('Berhasil', 'Success');

  Color get amountColor => isIncome ? AppColors.success : AppColors.danger;

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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: transaction.iconBackground,
      ),
      child: Icon(
        transaction.icon,
        size: size * 0.5,
        color: transaction.iconColor,
      ),
    );
  }
}
