import 'package:mobile_apps_recan/utils/localization.dart';

enum ActivityType { deposit, redeem }

class ActivityTransaction {
  const new({
    required this.transactionId,
    required this.type,
    required this._title,
    required this._titleEn,
    required this.timestamp,
    required this.points,
    required this.weightKg,
  });

  final String transactionId;
  final ActivityType type;
  final String _title;
  final String _titleEn;
  final DateTime timestamp;
  final int points;
  final double weightKg;

  String get title => tr(_title, _titleEn);

  bool get isIncome => points > 0;
}
