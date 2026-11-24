import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/services/mock_stations.dart';

class StationService {
  const new _();

  static const LatLng userPosition = MockStations.userPosition;

  static List<MapStation> get stations => MockStations.mapStations;

  static Future<List<MapStation>> fetchAll() => SynchronousFuture(stations);
}
