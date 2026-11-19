import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';

/// Visual spec shared by every mutually exclusive, full-width switch in the
/// app (quest period, carbon range, catalog tabs) so they read as one control.
abstract final class SegmentedStyle {
  static const double height = 44;
  static const double _trackRadius = 16;
  static const double _thumbRadius = 12;

  static BoxDecoration track(BuildContext context) => BoxDecoration(
    color: context.palette.surfaceMuted,
    borderRadius: BorderRadius.circular(_trackRadius),
  );

  static BoxDecoration thumb(BuildContext context) => BoxDecoration(
    color: context.palette.surface,
    borderRadius: BorderRadius.circular(_thumbRadius),
    border: Border.all(color: context.palette.border),
  );

  static BorderRadius get splashRadius => BorderRadius.circular(_thumbRadius);

  static TextStyle? label(BuildContext context, {required bool active}) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
        color: active ? AppColors.primary : context.palette.textSecondary,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      );
}

/// Segmented look for a [TabBar]; needs a [DefaultTabController] ancestor.
class SegmentedTabBar extends StatelessWidget {
  const new({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: SegmentedStyle.track(context),
        child: TabBar(
          dividerColor: AppColors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          splashBorderRadius: SegmentedStyle.splashRadius,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.palette.textSecondary,
          labelPadding: EdgeInsets.zero,
          labelStyle: SegmentedStyle.label(context, active: true),
          unselectedLabelStyle: SegmentedStyle.label(context, active: false),
          indicator: SegmentedStyle.thumb(context),
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
      decoration: SegmentedStyle.track(context),
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: _Segment(
                label: labelOf(value),
                active: value == selected,
                onTap: () {
                  if (value != selected) Haptics.selection();
                  onSelected(value);
                },
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
            ? SegmentedStyle.thumb(context)
            : BoxDecoration(borderRadius: SegmentedStyle.splashRadius),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SegmentedStyle.label(context, active: active),
        ),
      ),
    );
  }
}
