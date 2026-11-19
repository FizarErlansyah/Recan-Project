import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class HelpfulBonusCard extends StatefulWidget {
  const new({required this.articleId, super.key});

  final int articleId;

  @override
  State<HelpfulBonusCard> createState() => _HelpfulBonusCardState();
}

class _HelpfulBonusCardState extends State<HelpfulBonusCard> {
  static const List<Color> _confettiColors = [
    AppColors.primarySoft,
    AppColors.primary,
    AppColors.goldLight,
    AppColors.gold,
  ];

  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1200),
  );
  late bool _claimed = EducationService.isHelpfulClaimed(widget.articleId);

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    try {
      await EducationService.claimHelpfulBonus(widget.articleId);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, error.message);
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    setState(() => _claimed = true);
    _confetti.play();
    AppSnackBar.show(
      context,
      tr(
        'Terima kasih! +${EducationService.helpfulBonusPoints} poin edukasi',
        'Thank you! +${EducationService.helpfulBonusPoints} education points',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const bonus = EducationService.helpfulBonusPoints;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            tr('Apakah artikel ini bermanfaat?', 'Was this article helpful?'),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              'Beri tanda dan dapatkan bonus poin edukasi sekali klaim.',
              'Let us know and get a one-time education points bonus.',
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _claimed ? null : _claim,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.primaryDeep,
                    disabledBackgroundColor: AppColors.goldSoft,
                    disabledForegroundColor: AppColors.goldDeep,
                    shape: const StadiumBorder(),
                  ),
                  icon: HugeIcon(
                    icon: _claimed ? AppIcons.checkCircle : AppIcons.thumbsUp,
                    size: 20,
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _claimed
                          ? tr('Bonus sudah diklaim', 'Bonus claimed')
                          : tr(
                              'Ya, bermanfaat! +$bonus Poin',
                              'Yes, helpful! +$bonus Points',
                            ),
                      key: ValueKey(_claimed),
                      style: textTheme.labelLarge?.copyWith(
                        color: _claimed
                            ? AppColors.goldDeep
                            : AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: -pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 16,
                  maxBlastForce: 14,
                  minBlastForce: 4,
                  gravity: 0.3,
                  colors: _confettiColors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
