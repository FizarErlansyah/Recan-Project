import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

extension ActivityStyle on ActivityTransaction {
  bool get isDeposit => type == ActivityType.deposit;

  String get typeLabel => switch (type) {
    ActivityType.deposit => tr('Setoran Kaleng', 'Can Deposit'),
    ActivityType.redeem => tr('Penukaran Produk', 'Product Redemption'),
    ActivityType.quest => tr('Hadiah Misi', 'Quest Reward'),
    ActivityType.checkin => tr('Check-in Harian', 'Daily Check-in'),
    ActivityType.bonus => tr('Bonus Edukasi', 'Education Bonus'),
  };

  AppIconBuilder get icon => switch (type) {
    ActivityType.deposit => hugeIcon(HugeIcons.strokeRoundedRecycle01),
    ActivityType.redeem => hugeIcon(HugeIcons.strokeRoundedShoppingBag01),
    ActivityType.quest => hugeIcon(HugeIcons.strokeRoundedAward01),
    ActivityType.checkin => hugeIcon(HugeIcons.strokeRoundedCalendarCheckIn01),
    ActivityType.bonus => hugeIcon(HugeIcons.strokeRoundedBookOpen01),
  };

  String get locationLabel => switch (type) {
    ActivityType.deposit => 'Drop Station',
    ActivityType.redeem => tr('Katalog ReCan', 'ReCan Catalog'),
    ActivityType.quest ||
    ActivityType.checkin => tr('Misi & Hadiah', 'Quests & Rewards'),
    ActivityType.bonus => tr('Edukasi ReCan', 'ReCan Education'),
  };

  int get _cash => payment?.cashPaid ?? 0;

  bool get isSimulated => payment?.simulated ?? false;

  String get statusLabel =>
      isSimulated ? tr('Simulasi', 'Simulated') : tr('Berhasil', 'Success');

  Color amountColor(BuildContext context) =>
      isIncome ? context.palette.success : context.palette.danger;

  String get amountLabel {
    if (points == 0 && _cash > 0) return '-${formatRupiah(_cash)}';
    final sign = isIncome ? '+' : '-';
    return '$sign${formatPoints(points.abs())}';
  }

  /// The rupiah part of a hybrid order, shown under the points amount.
  String? get extraAmountLabel =>
      points != 0 && _cash > 0 ? '+ ${formatRupiah(_cash)}' : null;
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
        color: transaction.isIncome
            ? context.palette.tint
            : context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: transaction.icon(
        // Earnings read as brand colour; redemptions as neutral aluminium so
        // a spend never competes visually with an earn.
        color: transaction.isIncome
            ? context.palette.accent
            : (context.isDark
                  ? context.palette.textSecondary
                  : AppColors.slate),
        size: (size * 0.5).clamp(22, 24),
      ),
    );
  }
}
