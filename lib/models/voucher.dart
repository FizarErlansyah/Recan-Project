import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
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
  });

  /// Reads a `catalog_items` row of type voucher.
  factory fromJson(Map<String, dynamic> json) => Voucher(
    id: json['id'] as int,
    titleId: json['name'] as String,
    titleEn: json['name_en'] as String,
    descriptionId: json['description'] as String,
    descriptionEn: json['description_en'] as String,
    pointsCost: (json['price_points'] as num).toInt(),
    icon: _iconFor(json['icon_key'] as String?),
    colors: _gradientFrom(json['gradient_hex'] as List<dynamic>?),
  );

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
    return colors.length >= 2
        ? colors
        : const [AppColors.primary, AppColors.primaryDark];
  }

  final int id;
  final String titleId;
  final String titleEn;
  final String descriptionId;
  final String descriptionEn;
  final int pointsCost;
  final IconGlyph icon;
  final List<Color> colors;

  String get title => tr(titleId, titleEn);
  String get description => tr(descriptionId, descriptionEn);
}

class OwnedVoucher {
  const new({
    required this.voucher,
    required this.reference,
    required this.redeemedAt,
  });

  /// Reads an `owned_vouchers` row with its `catalog_items` row embedded.
  factory fromJson(Map<String, dynamic> json) => OwnedVoucher(
    voucher: Voucher.fromJson(json['catalog_items'] as Map<String, dynamic>),
    reference: json['reference'] as String,
    redeemedAt: DateTime.parse(json['redeemed_at'] as String).toLocal(),
  );

  final Voucher voucher;
  final String reference;
  final DateTime redeemedAt;
}
