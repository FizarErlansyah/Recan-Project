import 'dart:math';

import 'package:mobile_apps_recan/utils/localization.dart';

enum PaymentMode {
  points,
  cash,
  hybrid;

  static PaymentMode of({required int pointsUsed, required bool paysCash}) {
    if (!paysCash) return points;
    return pointsUsed > 0 ? hybrid : cash;
  }

  String get label => switch (this) {
    points => 'ReCan Points',
    cash => tr('Rupiah', 'Rupiah'),
    hybrid => tr('Poin + Rupiah', 'Points + Rupiah'),
  };
}

/// Rupiah payment options. No gateway is connected yet: the server records
/// them as simulated.
enum PaymentChannel {
  qris('qris'),
  bankTransfer('bank_transfer'),
  ewallet('ewallet');

  new(this.code);

  /// Value stored in `transactions.payment_channel`.
  final String code;

  static PaymentChannel? parse(String? raw) {
    for (final channel in values) {
      if (channel.code == raw) return channel;
    }
    return null;
  }

  String get title => switch (this) {
    qris => 'QRIS',
    bankTransfer => tr('Transfer Bank', 'Bank Transfer'),
    ewallet => 'E-Wallet',
  };

  String get subtitle => switch (this) {
    qris => tr('Scan dengan aplikasi apa saja', 'Scan with any app'),
    bankTransfer => tr(
      'Virtual account semua bank',
      'Virtual account, any bank',
    ),
    ewallet => 'GoPay, OVO, DANA',
  };
}

/// Price split of one order before it is sent. The server recomputes it with
/// the same rounding, and its answer is what the receipt shows.
class PaymentQuote {
  const new _({
    required this.grossIdr,
    required this.fullPoints,
    required this.maxUsablePoints,
    required this.pointsUsed,
  });

  factory of({
    required int unitPriceIdr,
    required int unitPricePoints,
    required int quantity,
    required int balance,
    required int requestedPoints,
  }) {
    final gross = unitPriceIdr * quantity;
    final full = unitPricePoints * quantity;
    final usable = max(0, min(balance, full));
    final wanted = requestedPoints.clamp(0, usable);
    final worthless = wanted < full && discountFor(wanted, gross, full) == 0;
    return PaymentQuote._(
      grossIdr: gross,
      fullPoints: full,
      maxUsablePoints: usable,
      pointsUsed: worthless ? 0 : wanted,
    );
  }

  /// Rupiah taken off by [points], in proportion to the product's own
  /// rupiah and point prices, rounded down.
  static int discountFor(int points, int grossIdr, int fullPoints) =>
      fullPoints <= 0 ? 0 : grossIdr * points ~/ fullPoints;

  final int grossIdr;
  final int fullPoints;
  final int maxUsablePoints;
  final int pointsUsed;

  int get discountIdr => discountFor(pointsUsed, grossIdr, fullPoints);

  int get cashDue => grossIdr - discountIdr;

  PaymentMode get mode =>
      PaymentMode.of(pointsUsed: pointsUsed, paysCash: cashDue > 0);
}

/// How an order was settled, as confirmed by the backend.
class PurchaseReceipt {
  const new({
    required this.reference,
    required this.pointsUsed,
    required this.cashPaid,
    this.grossIdr,
    this.channel,
    this.simulated = false,
  });

  /// Reads the row returned by `redeem_reward`.
  factory fromRedeemRow(Map<String, dynamic> json) => PurchaseReceipt(
    reference: json['reference'] as String,
    pointsUsed: (json['points_spent'] as num).toInt(),
    cashPaid: (json['cash_paid'] as num).toInt(),
    grossIdr: (json['gross_idr'] as num?)?.toInt(),
    channel: PaymentChannel.parse(json['payment_channel'] as String?),
    simulated: json['payment_status'] == 'simulated',
  );

  /// Reads the payment columns of a `transactions` row.
  factory fromTransactionRow(Map<String, dynamic> json) => PurchaseReceipt(
    reference: json['reference'] as String,
    pointsUsed: (json['points_used'] as num).toInt(),
    cashPaid: (json['cash_paid'] as num).toInt(),
    grossIdr: (json['gross_idr'] as num?)?.toInt(),
    channel: PaymentChannel.parse(json['payment_channel'] as String?),
    simulated: json['payment_status'] == 'simulated',
  );

  final String reference;
  final int pointsUsed;
  final int cashPaid;

  /// Rupiah price before the discount; null for items priced in points only.
  final int? grossIdr;
  final PaymentChannel? channel;

  /// The rupiah part was recorded without any gateway confirming it.
  final bool simulated;

  PaymentMode get mode =>
      PaymentMode.of(pointsUsed: pointsUsed, paysCash: cashPaid > 0);

  int? get discountIdr {
    final gross = grossIdr;
    return gross == null ? null : gross - cashPaid;
  }
}
