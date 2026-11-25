import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/capsule_progress_bar.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/tier_benefit_card.dart';
import 'package:mobile_apps_recan/widgets/tier_style.dart';

class TierInfoPage extends StatelessWidget {
  const new({required this.points, super.key});

  final int points;

  static void open(BuildContext context, int points) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: TierInfoPage(points: points)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = MemberTier.of(points);

    return Scaffold(
      appBar: AppBar(title: Text(tr('Tier Member', 'Member Tier'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _TierHeader(tier: current, points: points),
          const SizedBox(height: 32),
          Text(
            tr('Keuntungan Tiap Tier', 'Benefits of Each Tier'),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              'Naik tier, nikmati lebih banyak keuntungan',
              'Level up and enjoy more benefits',
            ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final tier in MemberTier.all) ...[
            TierBenefitCard(
              tier: tier,
              isCurrent: tier == current,
              isReached: tier.rank < current.rank,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  const new({required this.tier, required this.points});

  final MemberTier tier;
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final target = tier.target;
    final color = TierStyle.colorFor(tier);
    final message = target == null
        ? tr(
            'Kamu sudah di tier tertinggi. Terima kasih, Pahlawan Lingkungan!',
            'You are at the highest tier. Thank you, Environmental Hero!',
          )
        : tr(
            'Kumpulkan ${PointsHeader.formatNumber(target - points)} poin lagi '
                'untuk naik ke ${tier.nextName}',
            'Collect ${PointsHeader.formatNumber(target - points)} more '
                'points to reach ${tier.nextName}',
          );

    return MetallicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: HugeIcon(icon: AppIcons.medal, size: 52, color: color),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${tier.name} Member',
            style: textTheme.headlineSmall?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              '${PointsHeader.formatNumber(points)} poin',
              '${PointsHeader.formatNumber(points)} points',
            ),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primarySoft),
          ),
          const SizedBox(height: 16),
          CapsuleProgressBar(
            value: tier.progress(points),
            height: 6,
            trackColor: AppColors.white.withValues(alpha: 0.18),
            colors: const [AppColors.primarySoft, AppColors.primarySoft],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
