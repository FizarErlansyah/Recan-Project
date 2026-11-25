import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';
import 'package:mobile_apps_recan/widgets/quest_card.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

class DailyQuestSection extends StatefulWidget {
  const new({
    required this.future,
    required this.onRetry,
    required this.onUnauthorized,
    super.key,
    this.initialData,
  });

  final Future<GamificationData> future;
  final GamificationData? initialData;
  final VoidCallback onRetry;
  final VoidCallback onUnauthorized;

  @override
  State<DailyQuestSection> createState() => _DailyQuestSectionState();
}

class _DailyQuestSectionState extends State<DailyQuestSection> {
  final Set<int> _claimedIds = {};
  final Set<int> _claimingIds = {};
  QuestPeriod _period = QuestPeriod.daily;

  Future<bool> _claim(DailyQuest quest) async {
    if (_claimingIds.contains(quest.id)) return false;
    setState(() {
      _claimingIds.add(quest.id);
    });

    try {
      await GamificationService.claim(quest.id);
      if (!mounted) return false;
      setState(() {
        _claimingIds.remove(quest.id);
        _claimedIds.add(quest.id);
      });
      unawaited(HapticFeedback.mediumImpact());
      AppSnackBar.show(
        context,
        tr('Misi berhasil diklaim!', 'Mission claimed successfully!'),
      );
      return true;
    } on ApiException catch (error) {
      if (!mounted) return false;
      setState(() {
        _claimingIds.remove(quest.id);
      });
      if (error.unauthorized) {
        widget.onUnauthorized();
        return false;
      }
      AppSnackBar.show(context, error.message);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: tr('Misi', 'Missions'),
          subtitle: tr(
            'Selesaikan misi, kumpulkan poin ekstra',
            'Complete missions, earn extra points',
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder<GamificationData>(
            future: widget.future,
            initialData: widget.initialData,
            builder: (context, snapshot) {
              final error = snapshot.error;
              if (snapshot.data == null &&
                  snapshot.connectionState != ConnectionState.done) {
                return const _QuestSkeleton();
              }
              if (error != null) {
                final unauthorized =
                    error is ApiException && error.unauthorized;
                return _QuestMessage(
                  message: error is ApiException
                      ? error.message
                      : tr(
                          'Terjadi kesalahan tak terduga.',
                          'An unexpected error occurred.',
                        ),
                  actionLabel: unauthorized
                      ? tr('Masuk Kembali', 'Sign In Again')
                      : tr('Coba Lagi', 'Try Again'),
                  onAction: unauthorized
                      ? widget.onUnauthorized
                      : widget.onRetry,
                );
              }
              final allQuests = snapshot.data?.dailyQuests ?? const [];
              final quests = allQuests
                  .where((quest) => quest.period == _period)
                  .toList();
              if (allQuests.isEmpty) {
                return _QuestMessage(
                  message: tr(
                    'Belum ada misi untuk hari ini.',
                    'No missions for today yet.',
                  ),
                );
              }
              return Column(
                children: [
                  SegmentedPills<QuestPeriod>(
                    values: QuestPeriod.values,
                    selected: _period,
                    labelOf: (period) => period.label,
                    onSelected: (value) => setState(() => _period = value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _period.resetLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  for (final quest in quests) ...[
                    QuestCard(
                      // Without a key a tab switch would hand one quest's
                      // card state to another quest.
                      key: ValueKey(quest.id),
                      quest: _claimedIds.contains(quest.id)
                          ? quest.claimed()
                          : quest,
                      isClaiming: _claimingIds.contains(quest.id),
                      onClaim: () => _claim(quest),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuestSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        children: [
          ShimmerBox(height: 104),
          SizedBox(height: 12),
          ShimmerBox(height: 104),
        ],
      ),
    );
  }
}

class _QuestMessage extends StatelessWidget {
  const new({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (label != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: context.palette.accent,
              ),
              child: Text(label),
            ),
          ],
        ],
      ),
    );
  }
}
