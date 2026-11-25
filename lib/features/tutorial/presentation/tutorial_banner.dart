import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/tutorial/domain/can_tutorial.dart';
import 'package:mobile_apps_recan/features/tutorial/presentation/can_tutorial_page.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';

/// The way into the craft tutorial, at the top of Edukasi.
class TutorialBanner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      haptic: true,
      child: DecoratedBox(
        decoration: AppDecorations.hero(radius: AppDecorations.radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDecorations.radius),
            onTap: () => CanTutorialPage.open(context),
            child: const _BannerBody(),
          ),
        ),
      ),
    );
  }
}

class _BannerBody extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _BannerText()),
          SizedBox(width: 12),
          HugeIcon(icon: AppIcons.chevronRight, color: AppColors.warm),
        ],
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = CanTutorial.steps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Tutorial Olah Kaleng', 'Can Craft Tutorial'),
          style: textTheme.titleLarge?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            '$count langkah membuat kriya dari kaleng bekas, dengan aman.',
            '$count steps to a safe craft from a used can.',
          ),
          style: textTheme.bodySmall?.copyWith(color: AppColors.primarySoft),
        ),
      ],
    );
  }
}
