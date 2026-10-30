import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/widgets/activity_tile.dart';

class ActivityHistoryList extends StatelessWidget {
  const new({required this.transactions, super.key});

  final List<ActivityTransaction> transactions;

  List<Object> _rows() {
    final rows = <Object>[];
    String? currentLabel;
    for (final transaction in transactions) {
      final label = IndonesianDate.relativeDay(transaction.timestamp);
      if (label != currentLabel) {
        rows.add(label);
        currentLabel = label;
      }
      rows.add(transaction);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = _rows();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is String) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 24, bottom: 8),
            child: Text(row, style: textTheme.titleMedium),
          );
        }
        final isLast = index == rows.length - 1 || rows[index + 1] is String;
        return ActivityTile(
          transaction: row as ActivityTransaction,
          isLast: isLast,
        );
      },
    );
  }
}
