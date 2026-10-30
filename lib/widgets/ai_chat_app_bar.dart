import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/pulsing_status_dot.dart';

class AiChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const new({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      toolbarHeight: 72,
      centerTitle: false,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.primary,
      elevation: 4,
      shadowColor: AppColors.shadowStrong,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ReCan AI Assistant 🤖',
            style: textTheme.titleLarge?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulsingStatusDot(),
              const SizedBox(width: 8),
              Text(
                tr(
                  'Aktif • AI Environment Specialist',
                  'Active • AI Environment Specialist',
                ),
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.sageLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
