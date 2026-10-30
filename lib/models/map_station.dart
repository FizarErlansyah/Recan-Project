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

  factory fromJson(Map<String, dynamic> json) => MapStation(
    id: json['id'] as int,
    name: json['name'] as String,
    position: LatLng(
      _number(json['latitude'] ?? json['lat']),
      _number(json['longitude'] ?? json['lng'] ?? json['lon']),
    ),
    capacityPercent: _number(json['capacity_percent']).round(),
  );

  static const int fullThreshold = 80;

  final int id;
  final String _name;
  final String _nameEn;
  final LatLng position;
  final int capacityPercent;

  String get name => tr(_name, _nameEn);

  bool get isAlmostFull => capacityPercent >= fullThreshold;

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.parse('$value');
  }
}
