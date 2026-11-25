import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/activity/domain/activity_filter.dart';
import 'package:mobile_apps_recan/features/activity/domain/month_summary.dart';
import 'package:mobile_apps_recan/features/activity/presentation/activity_day_card.dart';
import 'package:mobile_apps_recan/features/activity/presentation/month_summary_card.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/sliding_segments.dart';

/// The month at a glance, a type filter, then the history day by day.
class ActivityHistoryList extends StatefulWidget {
  const new({required this.transactions, super.key, this.now});

  final List<ActivityTransaction> transactions;

  /// Fixed clock for tests; the device clock otherwise.
  final DateTime? now;

  @override
  State<ActivityHistoryList> createState() => _ActivityHistoryListState();
}

class _ActivityHistoryListState extends State<ActivityHistoryList> {
  // Days past the first screenful arrive at once instead of queueing.
  static const int _staggered = 5;

  ActivityFilter _filter = ActivityFilter.all;

  /// Kept entries grouped by day label, in the order the server sent them.
  Map<String, List<ActivityTransaction>> _days(DateTime now) {
    final days = <String, List<ActivityTransaction>>{};
    for (final row in widget.transactions.where(_filter.keeps)) {
      final label = IndonesianDate.relativeDay(row.timestamp, now: now);
      days.putIfAbsent(label, () => []).add(row);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.now ?? DateTime.now();
    final days = _days(now).entries.toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        MonthSummaryCard(
          summary: MonthSummary.of(widget.transactions, now),
          month: now,
        ),
        const SizedBox(height: 16),
        SlidingSegments(
          labels: [for (final filter in ActivityFilter.values) filter.label],
          selectedIndex: _filter.index,
          onSelected: (index) =>
              setState(() => _filter = ActivityFilter.values[index]),
        ),
        if (days.isEmpty) const _NothingKept(),
        for (final (index, day) in days.indexed)
          StaggeredEntrance(
            key: ValueKey('${_filter.name}-${day.key}'),
            index: index.clamp(0, _staggered),
            child: ActivityDayCard(label: day.key, rows: day.value),
          ),
      ],
    );
  }
}

class _NothingKept extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        tr(
          'Belum ada aktivitas untuk filter ini.',
          'No activity for this filter yet.',
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
