import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/activity_tile.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// The three newest ledger entries, with a way into the full history.
class RecentActivityCard extends StatelessWidget {
  const new({required this.activities, required this.onSeeAll, super.key});

  static const int _shown = 3;

  final List<ActivityTransaction> activities;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final newest = [...activities]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final rows = newest.take(_shown).toList();

    return ReCanCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(onSeeAll: onSeeAll),
          if (rows.isEmpty)
            const _Empty()
          else
            for (final (index, row) in rows.indexed)
              ActivityTile(transaction: row, isLast: index == rows.length - 1),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const new({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    // The link drops under the title once large text leaves no room beside it.
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              tr('Riwayat Terakhir', 'Recent Activity'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _SeeAll(onTap: onSeeAll),
          ],
        ),
      ),
    );
  }
}

class _SeeAll extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: context.palette.accent,
      ),
      child: Text(tr('Lihat Semua', 'See All')),
    );
  }
}

class _Empty extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
      child: Text(
        tr(
          'Belum ada aktivitas. Setoran dan hadiahmu muncul di sini.',
          'No activity yet. Your deposits and rewards appear here.',
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
