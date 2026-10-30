import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class AiAvatar extends StatelessWidget {
  const new({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        border: Border.all(color: AppColors.primarySoft, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'AI',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.white),
      ),
    );
  }
}
