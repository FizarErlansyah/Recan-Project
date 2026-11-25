import 'package:mobile_apps_recan/features/rewards/domain/wib_calendar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum QuestPeriod {
  daily,
  weekly,
  monthly;

  String get label => switch (this) {
    daily => tr('Harian', 'Daily'),
    weekly => tr('Mingguan', 'Weekly'),
    monthly => tr('Bulanan', 'Monthly'),
  };

  String get resetLabel => switch (this) {
    daily => tr(
      'Reset setiap hari pukul 00:00 WIB',
      'Resets daily at 00:00 WIB',
    ),
    weekly => tr(
      'Reset setiap Senin pukul 00:00 WIB',
      'Resets every Monday at 00:00 WIB',
    ),
    monthly => tr(
      'Reset setiap tanggal 1 pukul 00:00 WIB',
      'Resets on the 1st at 00:00 WIB',
    ),
  };

  static QuestPeriod parse(String? raw) => QuestPeriod.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => daily,
  );
}

enum QuestMetric {
  cans,
  checkIn,
  product,
  voucher;

  static QuestMetric parse(String? raw) => QuestMetric.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => cans,
  );
}

class DailyQuest {
  const new({
    required this.id,
    required String title,
    required this.progress,
    required this.target,
    required String unit,
    required this.rewardPoints,
    required this.isClaimed,
    this.period = QuestPeriod.daily,
    this.metric = QuestMetric.cans,
    String? titleEn,
    String? unitEn,
  }) : _title = title,
       _titleEn = titleEn ?? title,
       _unit = unit,
       _unitEn = unitEn ?? unit;

  /// Reads a row of the `my_quest_status` view.
  factory fromJson(Map<String, dynamic> json) => DailyQuest(
    id: json['id'] as int,
    title: json['title'] as String,
    titleEn: json['title_en'] as String?,
    progress: (json['progress'] as num).toInt(),
    target: (json['target'] as num).toInt(),
    unit: json['unit'] as String? ?? 'Kaleng',
    unitEn: json['unit_en'] as String?,
    period: QuestPeriod.parse(json['period'] as String?),
    metric: QuestMetric.parse(json['metric'] as String?),
    rewardPoints: (json['reward_points'] as num).toInt(),
    isClaimed: json['is_claimed'] as bool? ?? false,
  );

  final int id;
  final QuestPeriod period;
  final QuestMetric metric;
  final String _title;
  final String _titleEn;
  final int progress;
  final int target;
  final String _unit;
  final String _unitEn;
  final int rewardPoints;
  final bool isClaimed;

  String get title => tr(_title, _titleEn);
  String get unit => tr(_unit, _unitEn);

  int get displayProgress => progress > target ? target : progress;

  bool get isCompleted => progress >= target;
  bool get canClaim => isCompleted && !isClaimed;

  double get ratio => target <= 0 ? 1 : (progress / target).clamp(0.0, 1.0);

  DailyQuest withProgress(int value) => DailyQuest(
    id: id,
    period: period,
    metric: metric,
    title: _title,
    titleEn: _titleEn,
    progress: value,
    target: target,
    unit: _unit,
    unitEn: _unitEn,
    rewardPoints: rewardPoints,
    isClaimed: isClaimed,
  );

  DailyQuest claimed() => DailyQuest(
    id: id,
    period: period,
    metric: metric,
    title: _title,
    titleEn: _titleEn,
    progress: progress,
    target: target,
    unit: _unit,
    unitEn: _unitEn,
    rewardPoints: rewardPoints,
    isClaimed: true,
  );
}

/// Progress through the reward cycle. A missed day never resets it.
class DailyCheckIn {
  const new({
    required this.rewards,
    required this.claimedCount,
    required this.claimedToday,
    this.nextClaimAt,
  });

  /// Mirrors the `my_checkin_state` function for data kept on the device.
  factory fromHistory({
    required List<int> rewards,
    required DateTime now,
    DateTime? lastClaimDay,
    int lastIndex = 0,
  }) {
    if (lastClaimDay == null) {
      return DailyCheckIn(
        rewards: rewards,
        claimedCount: 0,
        claimedToday: false,
      );
    }
    final today = !lastClaimDay.isBefore(WibCalendar.dayOf(now));
    return DailyCheckIn(
      rewards: rewards,
      claimedCount: today ? lastIndex + 1 : (lastIndex + 1) % rewards.length,
      claimedToday: today,
      nextClaimAt: today ? WibCalendar.nextMidnight(now) : null,
    );
  }

  /// Reads the row of the `my_checkin_state` function.
  factory fromJson(Map<String, dynamic> json) {
    final next = json['next_claim_at'] as String?;
    return DailyCheckIn(
      rewards: [
        for (final value in json['rewards'] as List<dynamic>)
          (value as num).toInt(),
      ],
      claimedCount: (json['claimed_count'] as num).toInt(),
      claimedToday: json['claimed_today'] as bool,
      nextClaimAt: next == null ? null : DateTime.parse(next).toUtc(),
    );
  }

  final List<int> rewards;

  /// Days of the running cycle already claimed; days 1 to this one are done.
  final int claimedCount;
  final bool claimedToday;
  final DateTime? nextClaimAt;

  /// Zero-based day that was claimed today, or is waiting to be claimed.
  int get currentDay => claimedToday ? claimedCount - 1 : claimedCount;

  int get todayReward => rewards[currentDay];

  bool isClaimed(int day) => day < claimedCount;
}

class GamificationData {
  const new({required this.dailyQuests, required this.checkIn});

  final List<DailyQuest> dailyQuests;
  final DailyCheckIn checkIn;
}
