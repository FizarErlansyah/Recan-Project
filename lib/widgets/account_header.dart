import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_shadows.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';
import 'package:mobile_apps_recan/widgets/tier_style.dart';

class AccountHeader extends StatelessWidget {
  const new({required this.profile, super.key});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tier = MemberTier.of(profile.points);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ProfileAvatar(initials: profile.initials, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(profile.phone, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                _TierBadge(tier: tier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const new({required this.tier});

  final MemberTier tier;

  @override
  Widget build(BuildContext context) {
    final color = TierStyle.colorFor(tier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tier.emoji, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 4),
          Text(
            '${tier.name.toUpperCase()} MEMBER',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.textPrimary, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
