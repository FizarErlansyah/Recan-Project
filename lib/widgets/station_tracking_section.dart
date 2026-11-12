import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/drop_station_map_page.dart';
import 'package:mobile_apps_recan/services/station_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/drop_station_card.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';

class StationTrackingSection extends StatelessWidget {
  const new({required this.stations, required this.onLogout, super.key});

  final List<DropStation> stations;
  final VoidCallback onLogout;

  static const double mapHeight = 200;
  static const String _tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgentPackage = 'com.example.mobile_apps_recan';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: tr('Pelacakan Drop Station', 'Drop Station Tracking'),
            subtitle: tr(
              'Peta & status station secara langsung',
              'Live map & station status',
            ),
            actionLabel: tr('Lihat Semua', 'See All'),
            onAction: () =>
                DropStationMapPage.open(context, onLogout: onLogout),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SizedBox(
                  height: mapHeight,
                  child: RepaintBoundary(
                    child: GestureDetector(
                      onTap: () =>
                          DropStationMapPage.open(context, onLogout: onLogout),
                      child: const _MapPreview(),
                    ),
                  ),
                ),
                if (stations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        for (final station in stations) ...[
                          DropStationCard(station: station),
                          if (station != stations.last)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: StationService.campusCenter,
        initialZoom: 15.4,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: StationTrackingSection._tileUrl,
          userAgentPackageName: StationTrackingSection._userAgentPackage,
        ),
        MarkerLayer(
          markers: [
            for (final station in StationService.campusStations)
              Marker(
                point: station.position,
                width: 32,
                height: 32,
                alignment: Alignment.topCenter,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  size: 32,
                  color: station.isAlmostFull
                      ? AppColors.danger
                      : AppColors.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
