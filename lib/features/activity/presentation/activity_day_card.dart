import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/widgets/activity_tile.dart';

/// One day of history on its own card, under the day's name.
class ActivityDayCard extends StatelessWidget {
  const new({required this.label, required this.rows, super.key});

  final String label;
  final List<ActivityTransaction> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        _Rows(rows: rows),
      ],
    );
  }
}

class _Rows extends StatelessWidget {
  const new({required this.rows});

  final List<ActivityTransaction> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: AppDecorations.card(context),
      child: Column(
        children: [
          for (final (index, row) in rows.indexed)
            ActivityTile(transaction: row, isLast: index == rows.length - 1),
        ],
      ),
    );
  }
}
