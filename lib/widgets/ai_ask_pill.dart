import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

class AiAskPill extends StatelessWidget {
  const new({required this.onTap, super.key});

  static const double _pillHeight = 40;
  static const double _touchHeight = 48;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // The outer detector pads the hit area to 48dp while the ripple stays on
    // the visible 40dp pill.
    return Pressable(
      haptic: PressHaptic.selection,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: _touchHeight,
          child: Center(
            child: Material(
              color: AppColors.white.withValues(alpha: 0.10),
              shape: StadiumBorder(
                side: BorderSide(
                  color: AppColors.silverLight.withValues(alpha: 0.45),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  height: _pillHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedAiChat02,
                          size: 18,
                          color: AppColors.primarySoft,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr('Tanya AI', 'Ask AI'),
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
