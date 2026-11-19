import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class QuantityStepper extends StatelessWidget {
  const new({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canDecrease = enabled && value > min;
    final canIncrease = enabled && value < max;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: AppIcons.remove,
            tooltip: tr('Kurangi jumlah', 'Decrease quantity'),
            onTap: canDecrease ? () => onChanged(value - 1) : null,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: SizedBox(
              key: ValueKey(value),
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
            ),
          ),
          _StepperButton(
            icon: AppIcons.add,
            tooltip: tr('Tambah jumlah', 'Increase quantity'),
            onTap: canIncrease ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const new({required this.icon, required this.tooltip, required this.onTap});

  final IconGlyph icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: HugeIcon(icon: icon, size: 22),
      color: AppColors.primary,
      disabledColor: AppColors.textSecondary.withValues(alpha: 0.5),
    );
  }
}
