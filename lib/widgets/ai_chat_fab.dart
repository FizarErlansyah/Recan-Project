import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/pulsing_status_dot.dart';

class AiChatFab extends StatelessWidget {
  const new({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        alignment: Alignment.bottomRight,
        child: child,
      ),
      child: Tooltip(
        message: tr('Tanya ReCan AI', 'Ask ReCan AI'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowStrong,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            color: AppColors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                border: Border.all(
                  color: AppColors.primarySoft.withValues(alpha: 0.6),
                ),
              ),
              child: InkWell(
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Tanya ReCan AI', 'Ask ReCan AI'),
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const PulsingStatusDot(),
                                const SizedBox(width: 4),
                                Text(
                                  'AI Online',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.sageLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
