import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const new({required this.initials, super.key, this.size = 88});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(color: AppColors.primarySoft, width: 4),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(color: AppColors.white),
      ),
    );
  }
}
