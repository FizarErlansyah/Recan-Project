import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';

class CarbonRangeChips extends StatelessWidget {
  const new({required this.selected, required this.onSelected, super.key});

  final CarbonRange selected;
  final ValueChanged<CarbonRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in CarbonRange.values) ...[
            _RangeChip(
              label: range.label,
              active: range == selected,
              onTap: () => onSelected(range),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const new({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: active ? AppColors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
