import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class CapacityStyle {
  const new _();

  static Color colorFor(int percent) {
    if (percent > 80) return AppColors.danger;
    if (percent >= 50) return AppColors.warning;
    return AppColors.success;
  }
}
