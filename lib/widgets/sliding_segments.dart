import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

/// A full-width filter whose thumb slides to the chosen segment.
class SlidingSegments extends StatelessWidget {
  const new({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  void _select(int index) {
    if (index != selectedIndex) Haptics.selection();
    onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: SegmentedStyle.track(context),
      height: SegmentedStyle.height + 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Thumb(index: selectedIndex, count: labels.length),
          _Options(
            labels: labels,
            selectedIndex: selectedIndex,
            onSelected: _select,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const new({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    // -1 is flush left and 1 flush right, whatever the number of segments.
    final x = count < 2 ? 0.0 : -1 + 2 * index / (count - 1);

    return AnimatedAlign(
      duration: still ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment(x, 0),
      child: FractionallySizedBox(
        key: const ValueKey('segment-thumb'),
        widthFactor: 1 / count,
        heightFactor: 1,
        child: DecoratedBox(decoration: SegmentedStyle.thumb(context)),
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const new({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, label) in labels.indexed)
          Expanded(
            child: _Option(
              label: label,
              selected: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: SegmentedStyle.splashRadius,
          child: _SegmentLabel(label: label, selected: selected),
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const new({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: SegmentedStyle.label(context, active: selected),
          ),
        ),
      ),
    );
  }
}
