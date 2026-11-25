import 'dart:math';

import 'package:mobile_apps_recan/utils/localization.dart';

enum StationStatus {
  available,
  full,
  maintenance,
  offline;

  // An unknown value must not let a deposit start.
  static StationStatus parse(String? raw) => StationStatus.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => offline,
  );
}

/// The station behind a scanned QR code.
class ScannedStation {
  const new({
    required this.id,
    required String name,
    required this.status,
    required this.currentCans,
    required this.maxCapacity,
    required this.qrCode,
    String? nameEn,
  }) : _name = name,
       _nameEn = nameEn ?? name;

  /// Reads a row of the `station_by_qr` function.
  factory fromJson(Map<String, dynamic> json, {required String qrCode}) =>
      ScannedStation(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        nameEn: json['name_en'] as String?,
        status: StationStatus.parse(json['status'] as String?),
        currentCans: (json['current_cans'] as num).toInt(),
        maxCapacity: (json['max_capacity'] as num).toInt(),
        qrCode: qrCode,
      );

  static const int defaultCapacity = 300;

  final int id;
  final String _name;
  final String _nameEn;
  final StationStatus status;
  final int currentCans;
  final int maxCapacity;

  /// Sent back with the deposit as proof of the scan.
  final String qrCode;

  String get name => tr(_name, _nameEn);

  int get remaining => max(0, maxCapacity - currentCans);

  StationStatus get effectiveStatus =>
      status == StationStatus.available && remaining == 0
      ? StationStatus.full
      : status;

  bool get acceptsDeposits => effectiveStatus == StationStatus.available;
}
