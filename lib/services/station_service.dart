import 'package:latlong2/latlong.dart';

import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class StationService {
  const new _();

  // Stand-in for the device position until live location is wired in; it sits
  // in Pondok Aren so the Bintaro points read as nearest.
  static const LatLng userPosition = LatLng(-6.2880, 106.7290);

  static Future<List<MapStation>> fetchAll() => Backend.current.stations();

  static Future<MapStation?> findByQr(String code) =>
      Backend.current.stationByQr(code);
}
