import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/pages/drop_session_page.dart';
import 'package:mobile_apps_recan/services/station_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/shimmer.dart';
import 'package:mobile_apps_recan/widgets/station_bottom_sheet.dart';
import 'package:mobile_apps_recan/widgets/station_pin.dart';

class DropStationMapPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  static void open(BuildContext context, {required VoidCallback onLogout}) {
    Navigator.of(
      context,
    ).push(FadePageRoute<void>(page: DropStationMapPage(onLogout: onLogout)));
  }

  void _handleUnauthorized(BuildContext context) {
    Navigator.of(context).pop();
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Peta Drop Station', 'Drop Station Map'))),
      body: AsyncView<List<MapStation>>(
        loader: StationService.fetchAll,
        loading: const Shimmer(
          child: SizedBox.expand(
            child: ShimmerBox(radius: 0, height: double.infinity),
          ),
        ),
        onUnauthorized: () => _handleUnauthorized(context),
        builder: (context, stations, _) {
          if (stations.isEmpty) {
            return EmptyState(
              icon: hugeIcon(HugeIcons.strokeRoundedLocationOffline01),
              title: tr('Belum ada station', 'No stations yet'),
              message: tr(
                'Drop station belum tersedia di area kamu.',
                'Drop stations are not available in your area yet.',
              ),
            );
          }
          return _StationMap(stations: stations);
        },
      ),
    );
  }
}

class _StationMap extends StatelessWidget {
  const new({required this.stations});

  final List<MapStation> stations;

  static const double _zoom = 16;
  static const String _tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgentPackage = 'com.example.mobile_apps_recan';

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: StationService.campusCenter,
        initialZoom: _zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: _userAgentPackage,
          tileBuilder: context.isDark ? darkModeTileBuilder : null,
        ),
        MarkerLayer(
          markers: [
            for (final station in stations)
              Marker(
                point: station.position,
                width: StationPin.size,
                height: StationPin.size,
                alignment: Alignment.topCenter,
                child: StationPin(
                  station: station,
                  onTap: () => StationBottomSheet.show(
                    context,
                    station: station,
                    onDeposit: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        FadePageRoute<void>(
                          page: DropSessionPage(stationName: station.name),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }
}
