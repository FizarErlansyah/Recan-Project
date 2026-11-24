import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/pulsing_status_dot.dart';

class AiChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const new({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // The theme's AppBar iconTheme beats foregroundColor, so the back arrow
    // needs its own colour to stay visible on the emerald bar.
    return AppBar(
      toolbarHeight: 72,
      centerTitle: false,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: AppIcons.ai,
                size: 22,
                color: AppColors.primarySoft,
              ),
              const SizedBox(width: 8),
              Text(
                'ReCan AI Assistant',
                style: textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
            ],
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
                  color: AppColors.primarySoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
