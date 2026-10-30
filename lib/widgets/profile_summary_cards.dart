import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_shadows.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class ProfileSummaryCards extends StatelessWidget {
  const new({required this.points, required this.onTierTap, super.key});

  static const double height = 128;

  final int points;
  final VoidCallback onTierTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _TierCard(points: points, onTap: onTierTap),
          ),
          const SizedBox(width: 16),
          const Expanded(child: _VoucherCard()),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const new({required this.points, required this.onTap});

  final int points;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tier = MemberTier.of(points);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDeep],
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(tier.emoji, style: textTheme.titleLarge),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primarySoft,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(
                        '${PointsHeader.formatNumber(points)} poin',
                        '${PointsHeader.formatNumber(points)} points',
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primarySoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.confirmation_number_rounded,
            color: AppColors.primary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Voucher Saya', 'My Voucher'),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(tr('0 Aktif', '0 Active'), style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
