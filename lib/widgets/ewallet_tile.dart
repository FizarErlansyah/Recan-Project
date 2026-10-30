import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class EWalletTile extends StatelessWidget {
  const new({
    required this.option,
    required this.affordable,
    required this.onRedeem,
    super.key,
  });

  final EWalletOption option;
  final bool affordable;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ReCanCard(
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${PointsHeader.formatNumber(option.nominal)}',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    '${PointsHeader.formatNumber(option.pointsCost)} Poin',
                    '${PointsHeader.formatNumber(option.pointsCost)} Points',
                  ),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onRedeem,
              style: FilledButton.styleFrom(
                minimumSize: const Size(96, 48),
                backgroundColor: affordable
                    ? AppColors.primary
                    : AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                tr('Tukar', 'Redeem'),
                style: textTheme.labelLarge?.copyWith(
                  color: affordable ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
