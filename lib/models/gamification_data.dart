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

class DailyCheckIn {
  const new({
    required this.rewards,
    required this.todayIndex,
    required this.claimedDays,
  });

  final List<int> rewards;
  final int todayIndex;
  final Set<int> claimedDays;

  bool get claimedToday => claimedDays.contains(todayIndex);

  int get todayReward => rewards[todayIndex];
}

class GamificationData {
  const new({
    required this.streakDays,
    required this.dailyQuests,
    required this.checkIn,
  });

  final int streakDays;
  final List<DailyQuest> dailyQuests;
  final DailyCheckIn checkIn;
}
