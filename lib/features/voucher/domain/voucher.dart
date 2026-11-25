import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher_partner.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class Voucher {
  const new({
    required this.id,
    required this.titleId,
    required this.titleEn,
    required this.descriptionId,
    required this.descriptionEn,
    required this.pointsCost,
    required this.icon,
    required this.colors,
    this.termsId = const [],
    this.termsEn = const [],
    this.validityDays = defaultValidityDays,
    this.partners = const [],
  });

  /// Reads a `catalog_items` row of type voucher, with its `voucher_partners`
  /// embedded.
  factory fromJson(Map<String, dynamic> json) => Voucher(
    id: json['id'] as int,
    titleId: json['name'] as String,
    titleEn: json['name_en'] as String,
    descriptionId: json['description'] as String,
    descriptionEn: json['description_en'] as String,
    pointsCost: (json['price_points'] as num).toInt(),
    icon: _iconFor(json['icon_key'] as String?),
    colors: _gradientFrom(json['gradient_hex'] as List<dynamic>?),
    termsId: List<String>.from(json['terms'] as List<dynamic>? ?? const []),
    termsEn: List<String>.from(json['terms_en'] as List<dynamic>? ?? const []),
    validityDays:
        (json['validity_days'] as num?)?.toInt() ?? defaultValidityDays,
    partners: _partnersFrom(json['voucher_partners'] as List<dynamic>?),
  );

  // Matches the fallback of the expiry trigger in the database.
  static const int defaultValidityDays = 30;

  static IconGlyph _iconFor(String? key) => switch (key) {
    'meal' => AppIcons.meal,
    'parking' => AppIcons.parking,
    'print' => AppIcons.print,
    _ => AppIcons.gift,
  };

  static List<Color> _gradientFrom(List<dynamic>? hex) {
    final colors = [
      for (final value in hex ?? const <dynamic>[])
        Color(int.parse('FF${(value as String).substring(1)}', radix: 16)),
    ];
    return colors.length >= 2 ? colors : AppColors.heroGradient;
  }

  static List<VoucherPartner> _partnersFrom(List<dynamic>? rows) {
    final sorted = [...?rows?.cast<Map<String, dynamic>>()]
      ..sort(
        (a, b) => ((a['sort_order'] as num?) ?? 0).compareTo(
          (b['sort_order'] as num?) ?? 0,
        ),
      );
    return [for (final row in sorted) VoucherPartner.fromJson(row)];
  }

  final int id;
  final String titleId;
  final String titleEn;
  final String descriptionId;
  final String descriptionEn;
  final int pointsCost;
  final IconGlyph icon;
  final List<Color> colors;
  final List<String> termsId;
  final List<String> termsEn;
  final int validityDays;
  final List<VoucherPartner> partners;

  String get title => tr(titleId, titleEn);
  String get description => tr(descriptionId, descriptionEn);
  List<String> get terms => trValue(termsId, termsEn);
}

enum VoucherStatus {
  active,
  used,
  expired;

  static VoucherStatus parse(String? raw) => VoucherStatus.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => active,
  );

  String get label => switch (this) {
    active => tr('Aktif', 'Active'),
    used => tr('Terpakai', 'Used'),
    expired => tr('Kedaluwarsa', 'Expired'),
  };
}

class OwnedVoucher {
  const new({
    required this.voucher,
    required this.reference,
    required this.redeemedAt,
    this.status = VoucherStatus.active,
    this.usedAt,
    this.expiresAt,
  });

  /// Reads an `owned_vouchers` row with its `catalog_items` row embedded.
  factory fromJson(Map<String, dynamic> json) => OwnedVoucher(
    voucher: Voucher.fromJson(json['catalog_items'] as Map<String, dynamic>),
    reference: json['reference'] as String,
    redeemedAt: DateTime.parse(json['redeemed_at'] as String).toLocal(),
    status: VoucherStatus.parse(json['status'] as String?),
    usedAt: _time(json['used_at'] as String?),
    expiresAt: _time(json['expires_at'] as String?),
  );

  static DateTime? _time(String? raw) =>
      raw == null ? null : DateTime.parse(raw).toLocal();

  final Voucher voucher;
  final String reference;
  final DateTime redeemedAt;

  /// The stored status. The server never flips a row to expired by itself, so
  /// read [statusAt] for what the holder can actually do.
  final VoucherStatus status;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  VoucherStatus statusAt(DateTime now) {
    if (status != VoucherStatus.active) return status;
    final end = expiresAt;
    if (end == null || now.isBefore(end)) return VoucherStatus.active;
    return VoucherStatus.expired;
  }

  int? daysLeft(DateTime now) {
    final end = expiresAt;
    if (end == null) return null;
    return (end.difference(now).inMinutes / Duration.minutesPerDay).ceil();
  }

  OwnedVoucher markedUsed(DateTime at) => OwnedVoucher(
    voucher: voucher,
    reference: reference,
    redeemedAt: redeemedAt,
    status: VoucherStatus.used,
    usedAt: at,
    expiresAt: expiresAt,
  );
}
