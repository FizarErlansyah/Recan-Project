import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/utils/localization.dart';

class MapStation {
  const new({
    required this.id,
    required String name,
    required this.position,
    required this.capacityPercent,
    String? nameEn,
  }) : _name = name,
       _nameEn = nameEn ?? name;

  /// Reads a row of the `stations_with_distance` function.
  factory fromJson(Map<String, dynamic> json) => MapStation(
    id: json['id'] as int,
    name: json['name'] as String,
    nameEn: json['name_en'] as String?,
    position: LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
    capacityPercent: (json['capacity_percentage'] as num).round(),
  );

  static const int fullThreshold = 80;

  final int id;
  final String _name;
  final String _nameEn;
  final LatLng position;
  final int capacityPercent;

  String get name => tr(_name, _nameEn);

  bool get isAlmostFull => capacityPercent >= fullThreshold;
}
