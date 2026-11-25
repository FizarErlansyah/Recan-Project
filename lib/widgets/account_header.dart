import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';
import 'package:mobile_apps_recan/widgets/tier_style.dart';

class AccountHeader extends StatelessWidget {
  const new({required this.profile, super.key});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Identity(profile: profile),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Contact lines get the full card width and wrap, so an address is
          // never cut off.
          _ContactLine(icon: AppIcons.mail, value: profile.email),
          const SizedBox(height: 8),
          _ContactLine(icon: AppIcons.phone, value: profile.phone),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const new({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          initials: profile.initials,
          avatar: profile.avatar,
          size: 72,
        ),
        const SizedBox(width: 16),
        Expanded(child: _NameAndTier(profile: profile)),
      ],
    );
  }
}

class _NameAndTier extends StatelessWidget {
  const new({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _TierBadge(tier: MemberTier.of(profile.points)),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const new({required this.icon, required this.value});

  final IconGlyph icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(icon: icon, color: context.palette.textSecondary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
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
          hugeIcon(HugeIcons.strokeRoundedMedal01)(color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${tier.name.toUpperCase()} MEMBER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.palette.textPrimary,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
