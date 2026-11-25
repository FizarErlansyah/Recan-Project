import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// One glance at the running missions: how many are done, what can be claimed
/// and which one is closest.
class MissionRingCard extends StatelessWidget {
  const new({required this.quests, required this.onTap, super.key});

  final List<DailyQuest> quests;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = quests.where((quest) => quest.isCompleted).length;

    return ReCanCard(
      onTap: onTap,
      child: quests.isEmpty
          ? Text(
              tr('Belum ada misi aktif.', 'No active missions yet.'),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Row(
              children: [
                _ProgressRing(done: done, total: quests.length),
                const SizedBox(width: 16),
                Expanded(
                  child: _Summary(quests: quests, done: done),
                ),
              ],
            ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const new({required this.done, required this.total});

  static const double _size = 72;

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return SizedBox.square(
      dimension: _size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: done / total),
            duration: still ? Duration.zero : const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: context.palette.accent,
              backgroundColor: context.palette.surfaceMuted,
            ),
          ),
          _RingCount(label: '$done/$total'),
        ],
      ),
    );
  }
}

class _RingCount extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.quests, required this.done});

  final List<DailyQuest> quests;
  final int done;

  DailyQuest? get _closest {
    DailyQuest? best;
    for (final quest in quests) {
      if (quest.isCompleted) continue;
      if (best == null || quest.ratio > best.ratio) best = quest;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final claimable = quests.where((quest) => quest.canClaim).length;
    final next = _closest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Progres Misi', 'Mission Progress'),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          tr(
            '$done dari ${quests.length} misi selesai',
            '$done of ${quests.length} missions done',
          ),
          style: textTheme.bodySmall,
        ),
        if (claimable > 0) ...[
          const SizedBox(height: 4),
          Text(
            tr(
              '$claimable hadiah siap diklaim',
              '$claimable rewards ready to claim',
            ),
            style: textTheme.labelMedium?.copyWith(
              color: context.palette.goldText,
            ),
          ),
        ],
        if (next != null) ...[
          const SizedBox(height: 4),
          Text(
            tr(
              'Berikutnya: ${next.title} '
                  '(${next.displayProgress}/${next.target} ${next.unit})',
              'Next: ${next.title} '
                  '(${next.displayProgress}/${next.target} ${next.unit})',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
