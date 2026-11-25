import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/tier_style.dart';

class TierAndVoucherSection extends StatelessWidget {
  const new({
    required this.points,
    required this.activeVouchers,
    required this.onTierTap,
    required this.onVoucherTap,
    super.key,
  });

  static const double _gap = 12;

  final int points;
  final int activeVouchers;
  final VoidCallback onTierTap;
  final VoidCallback onVoucherTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _TierCard(points: points, onTap: onTierTap),
          ),
          const SizedBox(width: _gap),
          Expanded(
            flex: 2,
            child: _VoucherCard(count: activeVouchers, onTap: onVoucherTap),
          ),
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
            _TierMedal(key: const ValueKey('tier-medal'), accent: accent),
            const Spacer(),
            hugeIcon(HugeIcons.strokeRoundedArrowRight01)(
              color: AppColors.silverLight,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),
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
              style: textTheme.labelLarge?.copyWith(color: AppColors.warm),
            ),
            const SizedBox(height: 12),
            _NextTier(tier: tier, points: points),
          ],
        ),
      ],
    );
  }
}

/// How far the next tier is, as a bar and in points.
class _NextTier extends StatelessWidget {
  const new({required this.tier, required this.points});

  final MemberTier tier;
  final int points;

  @override
  Widget build(BuildContext context) {
    final goal = tier.target;
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: AppColors.silverLight);
    if (goal == null) {
      return Text(tr('Tier tertinggi', 'Highest tier'), style: style);
    }
    final left = PointsHeader.formatNumber(goal - points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TierBar(progress: tier.progress(points)),
        const SizedBox(height: 6),
        Text(
          tr(
            '$left poin lagi ke ${tier.nextName}',
            '$left points to ${tier.nextName}',
          ),
          style: style,
        ),
      ],
    );
  }
}

class _TierBar extends StatelessWidget {
  const new({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: still ? Duration.zero : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 6,
        color: AppColors.warm,
        backgroundColor: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _TierMedal extends StatelessWidget {
  const new({required this.accent, super.key});

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
  const new({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  color: context.palette.tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: hugeIcon(HugeIcons.strokeRoundedTicket01)(
                  color: context.palette.accent,
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count', style: textTheme.headlineSmall),
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
      ),
    );
  }
}
