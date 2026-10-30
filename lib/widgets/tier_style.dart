import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';

class TierStyle {
  const new _();

  static Color colorFor(MemberTier tier) {
    if (tier == MemberTier.gold) return AppColors.goldDeep;
    if (tier == MemberTier.silver) return AppColors.silver;
    return AppColors.bronze;
  }
}
