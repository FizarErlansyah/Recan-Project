import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class TierAndVoucherSection extends StatelessWidget {
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

  // Metallic hues are tier identity, so they only tint the badge and border;
  // the card body stays on the shared light surface.
  static Color _accentOf(MemberTier tier) => switch (tier.rank) {
    0 => AppColors.bronze,
    1 => AppColors.silver,
    _ => AppColors.goldDeep,
  };

  @override
  Widget build(BuildContext context) {
    final tier = MemberTier.of(points);
    final accent = _accentOf(tier);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _TierCardBody(tier: tier, accent: accent, points: points),
        ),
      ),
    );
  }
}

class _TierCardBody extends StatelessWidget {
  const new({required this.tier, required this.accent, required this.points});

  final MemberTier tier;
  final Color accent;
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _IconBadge(icon: Icons.workspace_premium_rounded, color: accent),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier.name, style: textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(
              tr(
                '${PointsHeader.formatNumber(points)} poin',
                '${PointsHeader.formatNumber(points)} points',
              ),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ],
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
            const _IconBadge(
              icon: Icons.confirmation_number_rounded,
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
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const new({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
