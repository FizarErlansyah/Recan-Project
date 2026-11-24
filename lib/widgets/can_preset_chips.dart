import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class CanPresetChips extends StatelessWidget {
  const new({required this.onPreset, super.key, this.enabled = true});

  final ValueChanged<int> onPreset;
  final bool enabled;

  static const int collectiveAmount = 1000;
  static const List<int> amounts = [5, 20, 100, collectiveAmount];

  static String labelFor(int amount) => amount == collectiveAmount
      ? tr(
          '+1000 (Kolektif Komunitas / Event)',
          '+1000 (Community Collective / Event)',
        )
      : '+$amount';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final amount in amounts)
          _PresetChip(
            label: labelFor(amount),
            onTap: enabled
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    onPreset(amount);
                  }
                : null,
          ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primarySoft.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primarySoft.withValues(alpha: 0.24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primarySoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
