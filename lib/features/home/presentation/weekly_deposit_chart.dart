import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/home/domain/weekly_deposits.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

String _dayName(DateTime date) => trValue(
  const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
)[date.weekday - 1];

String _cans(int count) {
  final number = AnimatedCountUp.format(count);
  return tr('$number kaleng', '$number cans');
}

/// Bar chart of the last seven days of deposits. Touching a day shows its
/// count in a dark tooltip; touching it again puts the tooltip away.
class WeeklyDepositChart extends StatefulWidget {
  const new({required this.week, required this.onScan, super.key});

  final WeeklyDeposits week;
  final VoidCallback onScan;

  @override
  State<WeeklyDepositChart> createState() => _WeeklyDepositChartState();
}

class _WeeklyDepositChartState extends State<WeeklyDepositChart> {
  int? _selected;

  void _select(int index) {
    Haptics.selection();
    setState(() => _selected = _selected == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final week = widget.week;

    return ReCanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('Setoran 7 Hari', '7-Day Deposits'),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            tr(
              '${_cans(week.total)} dalam 7 hari terakhir',
              '${_cans(week.total)} in the last 7 days',
            ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _TooltipLane(week: week, selected: _selected),
          const SizedBox(height: 4),
          _Bars(week: week, selected: _selected, onSelect: _select),
          if (week.total == 0) _EmptyNote(onScan: widget.onScan),
        ],
      ),
    );
  }
}

class _TooltipLane extends StatelessWidget {
  const new({required this.week, required this.selected});

  final WeeklyDeposits week;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final index = selected;
    final still = MediaQuery.disableAnimationsOf(context);

    // The lane keeps its height while empty, so the bars never jump.
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(14) + 18,
      child: index == null
          ? null
          : AnimatedAlign(
              duration: still
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              // Runs from flush left to flush right, so the bubble stays inside
              // the card whatever its width.
              alignment: Alignment(
                -1 + 2 * index / (WeeklyDeposits.length - 1),
                0,
              ),
              child: _Tooltip(day: week.days[index]),
            ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const new({required this.day});

  final DayDeposit day;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('week-tooltip'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${_dayName(day.date)} ${day.date.day} · ${_cans(day.cans)}',
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.white),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const new({
    required this.week,
    required this.selected,
    required this.onSelect,
  });

  static const double _height = 128;

  // With nothing to compare, a full-height plot would only be blank space.
  static const double _emptyHeight = 56;

  final WeeklyDeposits week;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: week.total == 0 ? _emptyHeight : _height,
      child: Row(
        children: [
          for (final (index, day) in week.days.indexed)
            Expanded(
              child: _DayColumn(
                key: ValueKey('week-bar-$index'),
                index: index,
                day: day,
                share: week.peak == 0 ? 0 : day.cans / week.peak,
                active: selected == index,
                dimmed: selected != null && selected != index,
                onTap: () => onSelect(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const new({
    required this.index,
    required this.day,
    required this.share,
    required this.active,
    required this.dimmed,
    required this.onTap,
    super.key,
  });

  final int index;
  final DayDeposit day;
  final double share;
  final bool active;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = _dayName(day.date);

    return Semantics(
      button: true,
      selected: active,
      label: '$name ${day.date.day}: ${_cans(day.cans)}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _DayStack(
          name: name,
          active: active,
          bar: _Bar(
            key: active ? ValueKey('week-active-$index') : null,
            fillKey: ValueKey('week-fill-$index'),
            share: share,
            active: active,
            dimmed: dimmed,
          ),
        ),
      ),
    );
  }
}

class _DayStack extends StatelessWidget {
  const new({required this.name, required this.active, required this.bar});

  final String name;
  final bool active;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: active ? context.palette.accent : context.palette.textSecondary,
      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
    );

    return Column(
      children: [
        Expanded(child: bar),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(name, style: style),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const new({
    required this.fillKey,
    required this.share,
    required this.active,
    required this.dimmed,
    super.key,
  });

  // An empty day still shows where its bar would stand.
  static const double _stub = 4;

  final Key fillKey;
  final double share;
  final bool active;
  final bool dimmed;

  Color _color(BuildContext context) {
    if (share == 0 && !active) return context.palette.border;
    final accent = context.palette.accent;
    if (active) return accent;
    return accent.withValues(alpha: dimmed ? 0.3 : 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.bottomCenter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: share),
          duration: still ? Duration.zero : const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, grown, _) => AnimatedContainer(
            key: fillKey,
            duration: still ? Duration.zero : const Duration(milliseconds: 160),
            width: active ? 22 : 18,
            height: _stub + (constraints.maxHeight - _stub) * grown,
            decoration: BoxDecoration(
              color: _color(context),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const new({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          tr(
            'Belum ada setoran dalam 7 hari terakhir.',
            'No deposits in the last 7 days.',
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: onScan,
          style: TextButton.styleFrom(foregroundColor: context.palette.accent),
          child: Text(tr('Pindai QR untuk setor', 'Scan a QR to deposit')),
        ),
      ],
    );
  }
}
