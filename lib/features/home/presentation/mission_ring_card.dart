import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// One glance at the running missions: how many are done, what can be claimed
/// and which one is closest.
class MissionRingCard extends StatelessWidget {
  const new({required this.quests, super.key, this.onTap});

  final List<DailyQuest> quests;
  final VoidCallback? onTap;

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
            builder: (context, value, _) => CustomPaint(
              painter: _RingPainter(
                value: value,
                track: context.palette.surfaceMuted,
                from: context.palette.accent,
                to: context.palette.success,
              ),
            ),
          ),
          _RingCount(label: '$done/$total'),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const new({
    required this.value,
    required this.track,
    required this.from,
    required this.to,
  });

  static const double _stroke = 8;

  final double value;
  final Color track;
  final Color from;
  final Color to;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(ring, 0, math.pi * 2, false, paint..color = track);
    if (value <= 0) return;
    // Starts at twelve o'clock; the gradient is turned to start there too.
    paint.shader = SweepGradient(
      colors: [from, to, from],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(ring);
    canvas.drawArc(ring, -math.pi / 2, math.pi * 2 * value, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.track != track ||
      oldDelegate.from != from ||
      oldDelegate.to != to;
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
