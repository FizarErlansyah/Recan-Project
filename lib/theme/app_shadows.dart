import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/theme/app_colors.dart';

class AppShadows {
  const new _();

  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];
}
