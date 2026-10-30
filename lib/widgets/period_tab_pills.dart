import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';

class PeriodTabPills extends StatelessWidget {
  const new({required this.selected, required this.onSelected, super.key});

  final QuestPeriod selected;
  final ValueChanged<QuestPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final period in QuestPeriod.values)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: period == selected
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelected(period),
                    child: SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          period.label,
                          style: textTheme.titleSmall?.copyWith(
                            color: period == selected
                                ? AppColors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
