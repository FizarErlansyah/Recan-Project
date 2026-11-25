import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
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
    this.busy = false,
  });

  final EWalletOption option;
  final bool affordable;
  final VoidCallback? onRedeem;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ReCanCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.palette.tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: HugeIcon(
                icon: AppIcons.wallet,
                color: context.palette.accent,
              ),
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
                    ? context.palette.primary
                    : context.palette.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: busy
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.onPrimary,
                      ),
                    )
                  : Text(
                      tr('Tukar', 'Redeem'),
                      style: textTheme.labelLarge?.copyWith(
                        color: affordable
                            ? context.palette.onPrimary
                            : context.palette.textSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
