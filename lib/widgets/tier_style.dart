import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';

class TierStyle {
  const new _();

  /// Rank accent for light surfaces (badges, borders, icon fills).
  static Color colorFor(MemberTier tier) {
    if (tier == MemberTier.gold) return AppColors.gold;
    if (tier == MemberTier.silver) return AppColors.silver;
    return AppColors.bronze;
  }

  /// Rank accent tuned for the dark emerald metallic card.
  static Color onDarkFor(MemberTier tier) {
    if (tier == MemberTier.gold) return AppColors.goldLight;
    if (tier == MemberTier.silver) return AppColors.silverLight;
    return AppColors.bronzeLight;
  }
}
