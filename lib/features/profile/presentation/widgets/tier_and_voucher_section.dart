import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/tier_style.dart';

class TierAndVoucherSection extends StatelessWidget {
  const new({required this.points, required this.onTierTap, super.key});

  static const double height = 128;
  static const double _gap = 12;

  final int points;
  final VoidCallback onTierTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _TierCard(points: points, onTap: onTierTap),
          ),
          const SizedBox(width: _gap),
          const Expanded(flex: 2, child: _VoucherCard()),
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
    final tier = MemberTier.of(points);

    return MetallicCard(
      radius: 16,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: _TierCardBody(tier: tier, points: points),
    );
  }
}

class _TierCardBody extends StatelessWidget {
  const new({required this.tier, required this.points});

  final MemberTier tier;
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = TierStyle.onDarkFor(tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _TierMedal(accent: accent),
            const Spacer(),
            hugeIcon(HugeIcons.strokeRoundedArrowRight01)(
              color: AppColors.silverLight,
              size: 20,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tier.name,
              style: textTheme.headlineSmall?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 2),
            Text(
              tr(
                '${PointsHeader.formatNumber(points)} poin',
                '${PointsHeader.formatNumber(points)} points',
              ),
              style: textTheme.labelLarge?.copyWith(color: AppColors.goldLight),
            ),
          ],
        ),
      ],
    );
  }
}

class _TierMedal extends StatelessWidget {
  const new({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryDeep.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.7)),
      ),
      child: hugeIcon(HugeIcons.strokeRoundedMedal01)(color: accent, size: 20),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: hugeIcon(HugeIcons.strokeRoundedTicket01)(
                color: AppColors.primary,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0', style: textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  tr('Voucher Aktif', 'Active Vouchers'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
