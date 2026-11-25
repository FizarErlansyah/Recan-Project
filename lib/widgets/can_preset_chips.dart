import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class CanPresetChips extends StatelessWidget {
  const new({
    required this.onPreset,
    required this.room,
    super.key,
    this.enabled = true,
  });

  final ValueChanged<int> onPreset;

  /// Cans that still fit; larger presets are disabled.
  final int room;
  final bool enabled;

  static const List<int> amounts = [1, 5, 10, 50];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final amount in amounts)
          _PresetChip(
            label: '+$amount',
            onTap: enabled && amount <= room
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
    final color = AppColors.primarySoft.withValues(
      alpha: onTap == null ? 0.35 : 1,
    );

    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: color.a * 0.6)),
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
                style: textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
