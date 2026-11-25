import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/rewards/domain/wib_calendar.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';
import 'package:mobile_apps_recan/widgets/single_flight.dart';

class DailyCheckInSection extends StatefulWidget {
  const new({required this.future, super.key, this.initialData});

  final Future<GamificationData> future;
  final GamificationData? initialData;

  @override
  State<DailyCheckInSection> createState() => _DailyCheckInSectionState();
}

class _DailyCheckInSectionState extends State<DailyCheckInSection> {
  // The state that was on screen when the claim succeeded. The button stays
  // locked until a newer one arrives, so the gap before the reload cannot be
  // tapped a second time.
  DailyCheckIn? _claimedFrom;

  Future<void> _claim(DailyCheckIn shown) async {
    try {
      await GamificationService.claimCheckIn();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, error.message);
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    if (!mounted) return;
    setState(() => _claimedFrom = shown);
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
            'Bolong sehari tidak mengulang dari awal',
            'Missing a day never starts you over',
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder<GamificationData>(
            future: widget.future,
            initialData: widget.initialData,
            builder: (context, snapshot) {
              final checkIn = snapshot.data?.checkIn;
              if (checkIn == null) return const SizedBox(height: 168);
              return SingleFlight(
                action: () => _claim(checkIn),
                builder: (context, run) => _CheckInCard(
                  checkIn: checkIn,
                  busy: run == null,
                  onClaim: identical(checkIn, _claimedFrom) ? null : run,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const new({required this.checkIn, required this.busy, required this.onClaim});

  final DailyCheckIn checkIn;
  final bool busy;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
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
          _CoinRow(checkIn: checkIn),
          const SizedBox(height: 16),
          _ClaimButton(checkIn: checkIn, busy: busy, onClaim: onClaim),
          if (checkIn.claimedToday) ...[
            const SizedBox(height: 8),
            _NextClaimNote(checkIn: checkIn),
          ],
        ],
      ),
    );
  }
}

class _CoinRow extends StatelessWidget {
  const new({required this.checkIn});

  final DailyCheckIn checkIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < checkIn.rewards.length; i++)
          Expanded(
            child: _CoinSlot(
              key: ValueKey(
                'checkin-$i-${checkIn.isClaimed(i) ? 'done' : 'open'}',
              ),
              day: i + 1,
              reward: checkIn.rewards[i],
              isCurrent: i == checkIn.currentDay,
              isClaimed: checkIn.isClaimed(i),
            ),
          ),
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const new({required this.checkIn, required this.busy, required this.onClaim});

  final DailyCheckIn checkIn;
  final bool busy;
  final VoidCallback? onClaim;

  String get _label {
    if (checkIn.claimedToday) return tr('Terklaim', 'Claimed');
    final day = checkIn.currentDay + 1;
    final reward = checkIn.todayReward;
    return tr(
      'Klaim Hari $day: +$reward Poin',
      'Claim Day $day: +$reward Points',
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimed = checkIn.claimedToday;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        key: const ValueKey('checkin-claim'),
        onPressed: claimed ? null : onClaim,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          disabledBackgroundColor: context.palette.goldSoft,
          shape: const StadiumBorder(),
        ),
        child: busy
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.palette.goldText,
                ),
              )
            : Text(
                _label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: claimed
                      ? context.palette.goldText
                      : AppColors.primaryDeep,
                ),
              ),
      ),
    );
  }
}

class _NextClaimNote extends StatelessWidget {
  const new({required this.checkIn});

  final DailyCheckIn checkIn;

  String get _text {
    final next = checkIn.claimedCount % checkIn.rewards.length + 1;
    final opensAt = checkIn.nextClaimAt;
    // Shown as the Jakarta date, whatever time zone the phone is set to.
    final date = opensAt == null
        ? tr('besok', 'tomorrow')
        : IndonesianDate.date(WibCalendar.dayOf(opensAt));
    return tr(
      'Klaim berikutnya (Hari $next): $date pukul 00:00 WIB',
      'Next claim (Day $next): $date at 00:00 WIB',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _CoinSlot extends StatelessWidget {
  const new({
    required this.day,
    required this.reward,
    required this.isCurrent,
    required this.isClaimed,
    super.key,
  });

  final int day;
  final int reward;
  final bool isCurrent;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Center(
            child: _Coin(isCurrent: isCurrent, isClaimed: isClaimed),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$reward',
          style: textTheme.labelMedium?.copyWith(
            color: isCurrent
                ? context.palette.accent
                : context.palette.textSecondary,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          tr('H$day', 'D$day'),
          style: textTheme.labelSmall?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Coin extends StatelessWidget {
  const new({required this.isCurrent, required this.isClaimed});

  final bool isCurrent;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCurrent ? 44 : 36,
      height: isCurrent ? 44 : 36,
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
        boxShadow: isCurrent && !isClaimed
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
        size: isCurrent ? 24 : 18,
        color: isClaimed ? context.palette.success : AppColors.white,
      ),
    );
  }
}
