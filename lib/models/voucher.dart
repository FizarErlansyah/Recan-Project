import 'package:flutter/material.dart';

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

  final Voucher voucher;
  final String reference;
  final DateTime redeemedAt;
}
