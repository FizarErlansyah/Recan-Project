import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class AppShadows {
  const new _();

  // Kept tight and low-alpha so cards read as grounded, not floating.
  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 2)),
  ];
}
