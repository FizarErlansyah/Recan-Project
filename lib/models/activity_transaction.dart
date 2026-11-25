import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum ActivityType {
  deposit,
  redeem,
  quest,
  checkin,
  bonus;

  static ActivityType parse(String? raw) => ActivityType.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => deposit,
  );
}

class ActivityTransaction {
  const new({
    required this.transactionId,
    required this.type,
    required this._title,
    required this._titleEn,
    required this.timestamp,
    required this.points,
    required this.weightKg,
    this.payment,
  });

  /// Reads a `transactions` row.
  factory fromJson(Map<String, dynamic> json) => ActivityTransaction(
    transactionId: json['reference'] as String,
    type: ActivityType.parse(json['type'] as String?),
    title: json['title'] as String,
    titleEn: json['title_en'] as String,
    timestamp: DateTime.parse(json['created_at'] as String).toLocal(),
    points: (json['points_delta'] as num).toInt(),
    weightKg: (json['weight_kg'] as num).toDouble(),
    payment: json['payment_method'] == null
        ? null
        : PurchaseReceipt.fromTransactionRow(json),
  );

  final String transactionId;
  final ActivityType type;
  final String _title;
  final String _titleEn;
  final DateTime timestamp;
  final int points;
  final double weightKg;

  /// How a catalog order was settled; null for every other kind of row.
  final PurchaseReceipt? payment;

  String get title => tr(_title, _titleEn);

  bool get isIncome => points > 0;
}
