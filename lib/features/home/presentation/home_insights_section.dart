import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/home/domain/weekly_deposits.dart';
import 'package:mobile_apps_recan/features/home/presentation/mission_ring_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/recent_activity_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/weekly_deposit_chart.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/activity_service.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';

typedef _Insights = ({
  List<ActivityTransaction> activities,
  GamificationData gamification,
});

/// The personal part of Beranda: this week's deposits, mission progress and
/// the latest entries. It loads apart from the dashboard so the balance card
/// never waits for it.
class HomeInsightsSection extends StatelessWidget {
  const new({
    required this.refreshOn,
    required this.onUnauthorized,
    required this.onScan,
    required this.onOpenQuests,
    required this.onSeeAllActivity,
    super.key,
  });

  final Listenable refreshOn;
  final VoidCallback onUnauthorized;
  final VoidCallback onScan;
  final VoidCallback onOpenQuests;
  final VoidCallback onSeeAllActivity;

  static Future<_Insights> _load() async {
    final (activities, gamification) = await (
      ActivityService.fetch(),
      GamificationService.fetch(),
    ).wait;
    return (activities: activities, gamification: gamification);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AsyncView<_Insights>(
        loader: _load,
        loading: const _InsightsSkeleton(),
        onUnauthorized: onUnauthorized,
        refreshOn: refreshOn,
        builder: (context, data, _) => _InsightCards(
          data: data,
          onScan: onScan,
          onOpenQuests: onOpenQuests,
          onSeeAllActivity: onSeeAllActivity,
        ),
      ),
    );
  }
}

class _InsightCards extends StatelessWidget {
  const new({
    required this.data,
    required this.onScan,
    required this.onOpenQuests,
    required this.onSeeAllActivity,
  });

  final _Insights data;
  final VoidCallback onScan;
  final VoidCallback onOpenQuests;
  final VoidCallback onSeeAllActivity;

  @override
  Widget build(BuildContext context) {
    final week = WeeklyDeposits.from(data.activities, DateTime.now());

    // Entrances continue the count started by the header and quick actions.
    return Column(
      children: [
        StaggeredEntrance(
          index: 3,
          child: WeeklyDepositChart(week: week, onScan: onScan),
        ),
        const SizedBox(height: 16),
        StaggeredEntrance(
          index: 4,
          child: MissionRingCard(
            quests: data.gamification.dailyQuests,
            onTap: onOpenQuests,
          ),
        ),
        const SizedBox(height: 16),
        StaggeredEntrance(
          index: 5,
          child: RecentActivityCard(
            activities: data.activities,
            onSeeAll: onSeeAllActivity,
          ),
        ),
      ],
    );
  }
}

class _InsightsSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        children: [
          ShimmerBox(height: 220, radius: 16),
          SizedBox(height: 16),
          ShimmerBox(height: 104, radius: 16),
          SizedBox(height: 16),
          ShimmerBox(height: 200, radius: 16),
        ],
      ),
    );
  }
}
