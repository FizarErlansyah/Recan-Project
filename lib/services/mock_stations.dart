import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/services/station_service.dart';

/// Single seed for every drop station, so the Beranda list, the map pins and
/// the distances can never disagree. Coordinates come from OpenStreetMap.
class MockStations {
  const new _();

  static const Distance _distance = Distance();

  static const List<_Seed> _seeds = [
    _Seed(
      id: 201,
      name: 'Drop Station Pasar Modern Bintaro',
      nameEn: 'Drop Station at Pasar Modern Bintaro',
      location: 'Pasar Modern Bintaro Sektor 7',
      locationEn: 'Pasar Modern Bintaro Sector 7',
      position: LatLng(-6.27960, 106.71938),
      capacityPercent: 35,
    ),
    _Seed(
      id: 202,
      name: 'Drop Station Stasiun Pondok Ranji',
      nameEn: 'Drop Station at Pondok Ranji Station',
      location: 'Stasiun KRL Pondok Ranji',
      locationEn: 'Pondok Ranji KRL Station',
      position: LatLng(-6.27668, 106.74469),
      capacityPercent: 85,
    ),
    _Seed(
      id: 203,
      name: 'Drop Station Bintaro Plaza',
      nameEn: 'Drop Station at Bintaro Plaza',
      location: 'Bintaro Plaza Sektor 3A',
      locationEn: 'Bintaro Plaza Sector 3A',
      position: LatLng(-6.27268, 106.74187),
      capacityPercent: 60,
    ),
    _Seed(
      id: 204,
      name: 'Drop Station Stasiun Jurang Mangu',
      nameEn: 'Drop Station at Jurang Mangu Station',
      location: 'Stasiun KRL Jurang Mangu',
      locationEn: 'Jurang Mangu KRL Station',
      position: LatLng(-6.28858, 106.72915),
      capacityPercent: 48,
    ),
    _Seed(
      id: 205,
      name: 'Drop Station Bintaro Jaya Xchange',
      nameEn: 'Drop Station at Bintaro Jaya Xchange',
      location: 'Bintaro Jaya Xchange Mall',
      locationEn: 'Bintaro Jaya Xchange Mall',
      position: LatLng(-6.28567, 106.72800),
      capacityPercent: 66,
    ),
    _Seed(
      id: 206,
      name: 'Drop Station AEON Mall BSD',
      nameEn: 'Drop Station at AEON Mall BSD',
      location: 'AEON Mall BSD City',
      locationEn: 'AEON Mall BSD City',
      position: LatLng(-6.30441, 106.64416),
      capacityPercent: 22,
    ),
    _Seed(
      id: 207,
      name: 'Drop Station Taman Kota 1 BSD',
      nameEn: 'Drop Station at Taman Kota 1 BSD',
      location: 'Taman Kota 1, BSD City',
      locationEn: 'Taman Kota 1, BSD City',
      position: LatLng(-6.28822, 106.67599),
      capacityPercent: 74,
    ),
    _Seed(
      id: 208,
      name: 'Drop Station Stasiun Rawa Buntu',
      nameEn: 'Drop Station at Rawa Buntu Station',
      location: 'Stasiun KRL Rawa Buntu',
      locationEn: 'Rawa Buntu KRL Station',
      position: LatLng(-6.31488, 106.67615),
      capacityPercent: 31,
    ),
  ];

  static final List<MapStation> mapStations = [
    for (final seed in _seeds)
      MapStation(
        id: seed.id,
        name: seed.name,
        nameEn: seed.nameEn,
        position: seed.position,
        capacityPercent: seed.capacityPercent,
      ),
  ];

  static final List<DropStation> dropStations = [
    for (final seed in _seeds)
      DropStation(
        id: seed.id,
        name: seed.name,
        nameEn: seed.nameEn,
        location: seed.location,
        locationEn: seed.locationEn,
        capacityPercentage: seed.capacityPercent,
        status: 'available',
        distanceMeters: _distance
            .as(LengthUnit.Meter, StationService.userPosition, seed.position)
            .round(),
      ),
  ];
}

class _Seed {
  const new({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.location,
    required this.locationEn,
    required this.position,
    required this.capacityPercent,
  });

  final int id;
  final String name;
  final String nameEn;
  final String location;
  final String locationEn;
  final LatLng position;
  final int capacityPercent;
}
