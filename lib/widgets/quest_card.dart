import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class QuestCard extends StatefulWidget {
  const new({
    required this.quest,
    required this.onClaim,
    super.key,
    this.isClaiming = false,
  });

  final DailyQuest quest;

  /// Resolves to true only when the server accepted the claim.
  final Future<bool> Function() onClaim;
  final bool isClaiming;

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1200),
  );

  // Confetti answers the tap itself. Watching the quest data instead would
  // celebrate again on every reload or tab switch.
  Future<void> _claim() async {
    final claimed = await widget.onClaim();
    if (!claimed || !mounted) return;
    if (!MediaQuery.disableAnimationsOf(context)) _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;

    return _ReadyFrame(
      ready: quest.canClaim,
      child: ReCanCard(
        child: Column(
          children: [
            _QuestSummary(quest: quest),
            if (quest.isClaimed || quest.canClaim) ...[
              const SizedBox(height: 16),
              _ClaimArea(
                confetti: _confetti,
                claimed: quest.isClaimed,
                claiming: widget.isClaiming,
                onPressed: _claim,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An amber rim on a reward that is waiting to be taken.
class _ReadyFrame extends StatelessWidget {
  const new({required this.ready, required this.child});

  final bool ready;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        border: ready
            ? Border.all(color: context.palette.warm, width: 2)
            : null,
      ),
      child: child,
    );
  }
}

class _QuestSummary extends StatelessWidget {
  const new({required this.quest});

  final DailyQuest quest;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestIcon(done: quest.isCompleted),
        const SizedBox(width: 12),
        Expanded(child: _QuestProgress(quest: quest)),
      ],
    );
  }
}

class _QuestIcon extends StatelessWidget {
  const new({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: AppDecorations.tinted(
        context,
        radius: AppDecorations.controlRadius,
      ),
      child: HugeIcon(
        icon: done ? AppIcons.medal : AppIcons.target,
        color: context.palette.accent,
      ),
    );
  }
}

class _QuestProgress extends StatelessWidget {
  const new({required this.quest});

  final DailyQuest quest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quest.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _ProgressBar(ratio: quest.ratio),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${quest.displayProgress}/${quest.target} ${quest.unit}',
              style: textTheme.bodySmall,
            ),
            _RewardChip(points: quest.rewardPoints),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const new({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: ratio),
      duration: still ? Duration.zero : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 8,
        color: ratio >= 1 ? context.palette.success : context.palette.accent,
        backgroundColor: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: context.palette.goldSoft,
        shape: const StadiumBorder(),
      ),
      child: _RewardLabel(points: points),
    );
  }
}

class _RewardLabel extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.goldText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: AppIcons.coins, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '+${formatPoints(points)}',
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ClaimArea extends StatelessWidget {
  const new({
    required this.confetti,
    required this.claimed,
    required this.claiming,
    required this.onPressed,
  });

  static const List<Color> _confettiColors = [
    AppColors.primarySoft,
    AppColors.primary,
    AppColors.warm,
    AppColors.gold,
  ];

  final ConfettiController confetti;
  final bool claimed;
  final bool claiming;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _ClaimButton(
          claimed: claimed,
          claiming: claiming,
          onPressed: onPressed,
        ),
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: confetti,
            blastDirection: -pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 14,
            maxBlastForce: 14,
            minBlastForce: 4,
            gravity: 0.3,
            colors: _confettiColors,
          ),
        ),
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const new({
    required this.claimed,
    required this.claiming,
    required this.onPressed,
  });

  final bool claimed;
  final bool claiming;
  final VoidCallback onPressed;

  String get _label {
    if (claimed) return tr('Selesai', 'Done');
    if (claiming) return tr('Memproses...', 'Processing...');
    return tr('Klaim', 'Claim');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: claimed || claiming ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.warm,
          foregroundColor: palette.onWarm,
          disabledBackgroundColor: claiming ? palette.warm : palette.goldSoft,
          disabledForegroundColor: claiming ? palette.onWarm : palette.goldText,
        ),
        icon: _ClaimIcon(claimed: claimed, claiming: claiming),
        label: Text(_label),
      ),
    );
  }
}

class _ClaimIcon extends StatelessWidget {
  const new({required this.claimed, required this.claiming});

  final bool claimed;
  final bool claiming;

  @override
  Widget build(BuildContext context) {
    if (claiming) {
      return SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.palette.onWarm,
        ),
      );
    }
    return HugeIcon(
      icon: claimed ? AppIcons.checkCircle : AppIcons.gift,
      size: 18,
    );
  }
}
