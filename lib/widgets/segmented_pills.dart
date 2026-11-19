import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Visual spec shared by every mutually exclusive, full-width switch in the
/// app (quest period, carbon range, catalog tabs) so they read as one control.
abstract final class SegmentedStyle {
  static const double height = 44;
  static const double _trackRadius = 16;
  static const double _thumbRadius = 12;

  static BoxDecoration track() => BoxDecoration(
    color: AppColors.surfaceMuted,
    borderRadius: BorderRadius.circular(_trackRadius),
  );

  static BoxDecoration thumb() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(_thumbRadius),
    border: Border.all(color: AppColors.border),
  );

  static BorderRadius get splashRadius => BorderRadius.circular(_thumbRadius);

  static TextStyle? label(TextTheme textTheme, {required bool active}) =>
      textTheme.titleSmall?.copyWith(
        color: active ? AppColors.primary : AppColors.textSecondary,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      );
}

/// Segmented look for a [TabBar]; needs a [DefaultTabController] ancestor.
class SegmentedTabBar extends StatelessWidget {
  const new({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: SegmentedStyle.track(),
        child: TabBar(
          dividerColor: AppColors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          splashBorderRadius: SegmentedStyle.splashRadius,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelPadding: EdgeInsets.zero,
          labelStyle: SegmentedStyle.label(textTheme, active: true),
          unselectedLabelStyle: SegmentedStyle.label(textTheme, active: false),
          indicator: SegmentedStyle.thumb(),
          tabs: [
            for (final label in labels)
              Tab(height: SegmentedStyle.height, text: label),
          ],
        ),
      ),
    );
  }
}

class SegmentedPills<T> extends StatelessWidget {
  const new({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: SegmentedStyle.track(),
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: _Segment(
                label: labelOf(value),
                active: value == selected,
                onTap: () => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const new({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: SegmentedStyle.splashRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: SegmentedStyle.height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: active
            ? SegmentedStyle.thumb()
            : BoxDecoration(borderRadius: SegmentedStyle.splashRadius),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SegmentedStyle.label(
            Theme.of(context).textTheme,
            active: active,
          ),
        ),
      ),
    );
  }
}
