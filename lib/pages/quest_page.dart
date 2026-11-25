import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/home/presentation/mission_ring_card.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/daily_checkin_section.dart';
import 'package:mobile_apps_recan/widgets/daily_quest_section.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';

/// Mission progress at a glance; stays out of the way until it is known.
class _Progress extends StatelessWidget {
  const new({required this.future, required this.initialData});

  final Future<GamificationData> future;
  final GamificationData? initialData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GamificationData>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        final quests = snapshot.data?.dailyQuests;
        if (quests == null || quests.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: MissionRingCard(quests: quests),
        );
      },
    );
  }
}

class QuestPage extends StatefulWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  static void open(BuildContext context, {required VoidCallback onLogout}) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: QuestPage(onLogout: onLogout)));
  }

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  late Future<GamificationData> _gamification = _fetchGamification();
  GamificationData? _latestGamification;

  @override
  void initState() {
    super.initState();
    DataRefresh.revision.addListener(_reload);
  }

  @override
  void dispose() {
    DataRefresh.revision.removeListener(_reload);
    super.dispose();
  }

  Future<GamificationData> _fetchGamification() {
    _latestGamification = GamificationService.current;
    return GamificationService.fetch();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _gamification = _fetchGamification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Misi & Hadiah', 'Quests & Rewards'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _Progress(future: _gamification, initialData: _latestGamification),
          DailyCheckInSection(
            future: _gamification,
            initialData: _latestGamification,
          ),
          const SizedBox(height: 24),
          DailyQuestSection(
            future: _gamification,
            initialData: _latestGamification,
            onRetry: _reload,
            onUnauthorized: widget.onLogout,
          ),
        ],
      ),
    );
  }
}
