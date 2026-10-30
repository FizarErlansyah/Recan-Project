import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/models/map_station.dart';

class StationService {
  const new _();

  static const LatLng campusCenter = LatLng(-6.2741, 106.7345);

  static final List<MapStation> campusStations = [
    const MapStation(
      id: 201,
      name: 'Drop Station Gedung Utama UPJ',
      nameEn: 'UPJ Main Building Drop Station',
      position: campusCenter,
      capacityPercent: 35,
    ),
    const MapStation(
      id: 202,
      name: 'Drop Station Kantin UPJ',
      nameEn: 'UPJ Canteen Drop Station',
      position: LatLng(-6.2736, 106.7351),
      capacityPercent: 85,
    ),
    const MapStation(
      id: 203,
      name: 'Drop Station Perpustakaan UPJ',
      nameEn: 'UPJ Library Drop Station',
      position: LatLng(-6.2747, 106.7338),
      capacityPercent: 60,
    ),
  ];

  static Future<List<MapStation>> fetchAll() =>
      SynchronousFuture(campusStations);
}
