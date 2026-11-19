import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';

class DailyCheckInSection extends StatelessWidget {
  const new({required this.future, super.key, this.initialData});

  final Future<GamificationData> future;
  final GamificationData? initialData;

  Future<void> _claim(BuildContext context) async {
    try {
      await GamificationService.claimCheckIn();
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.show(context, error.message);
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      tr('Hadiah harian berhasil diklaim!', 'Daily reward claimed!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: tr('Hadiah Harian', 'Daily Reward'),
          subtitle: tr(
            'Check-in tiap hari, poin makin banyak',
            'Check in every day for more points',
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder<GamificationData>(
            future: future,
            initialData: initialData,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) return const SizedBox(height: 168);
              return _CheckInCard(
                checkIn: data.checkIn,
                onClaim: () => _claim(context),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const new({required this.checkIn, required this.onClaim});

  final DailyCheckIn checkIn;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final claimed = checkIn.claimedToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < checkIn.rewards.length; i++)
                Expanded(
                  child: _CoinSlot(
                    reward: checkIn.rewards[i],
                    isToday: i == checkIn.todayIndex,
                    isClaimed: checkIn.claimedDays.contains(i),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: claimed ? null : onClaim,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                disabledBackgroundColor: context.palette.goldSoft,
                shape: const StadiumBorder(),
              ),
              child: Text(
                claimed
                    ? tr('Terklaim', 'Claimed')
                    : tr(
                        'Klaim +${checkIn.todayReward} Poin',
                        'Claim +${checkIn.todayReward} Points',
                      ),
                style: textTheme.labelLarge?.copyWith(
                  color: claimed
                      ? context.palette.goldText
                      : AppColors.primaryDeep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinSlot extends StatelessWidget {
  const new({
    required this.reward,
    required this.isToday,
    required this.isClaimed,
  });

  final int reward;
  final bool isToday;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isToday ? 44 : 36,
          height: isToday ? 44 : 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isClaimed ? context.palette.successSoft : null,
            gradient: isClaimed
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gold, AppColors.goldDeep],
                  ),
            boxShadow: isToday && !isClaimed
                ? const [
                    BoxShadow(
                      color: AppColors.goldDeep,
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: HugeIcon(
            icon: isClaimed ? AppIcons.check : AppIcons.coins,
            size: isToday ? 24 : 18,
            color: isClaimed ? context.palette.success : AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$reward',
          style: textTheme.labelMedium?.copyWith(
            color: isToday
                ? context.palette.accent
                : context.palette.textSecondary,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
