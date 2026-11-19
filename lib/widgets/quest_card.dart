import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
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
  final VoidCallback onClaim;
  final bool isClaiming;

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  static const List<Color> _confettiColors = [
    AppColors.primarySoft,
    AppColors.primary,
    AppColors.goldLight,
    AppColors.gold,
  ];

  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1200),
  );

  DailyQuest get quest => widget.quest;

  @override
  void didUpdateWidget(covariant QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.quest.isClaimed && widget.quest.isClaimed) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ReCanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: quest.isCompleted ? AppIcons.medal : AppIcons.target,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: quest.ratio),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        color: AppColors.primarySoft,
                        backgroundColor: AppColors.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quest.displayProgress}/${quest.target} ${quest.unit}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RewardChip(points: quest.rewardPoints),
            ],
          ),
          if (quest.isClaimed || quest.canClaim) ...[
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _ClaimButton(
                  claimed: quest.isClaimed,
                  claiming: widget.isClaiming,
                  onPressed: widget.onClaim,
                ),
                IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confetti,
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
            ),
          ],
        ],
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
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: AppIcons.coins,
            size: 14,
            color: AppColors.goldDeep,
          ),
          const SizedBox(width: 4),
          Text(
            tr('+$points Poin', '+$points Points'),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: AppColors.goldDeep),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final icon = claiming
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryDeep,
            ),
          )
        : HugeIcon(
            icon: claimed ? AppIcons.checkCircle : AppIcons.gift,
            size: 18,
          );

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: claimed || claiming ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.primaryDeep,
          disabledBackgroundColor: claiming
              ? AppColors.goldLight
              : AppColors.goldSoft,
          disabledForegroundColor: AppColors.goldDeep,
        ),
        icon: icon,
        label: Text(
          claimed
              ? tr('Selesai', 'Done')
              : claiming
              ? tr('Memproses...', 'Processing...')
              : tr('Klaim', 'Claim'),
        ),
      ),
    );
  }
}
