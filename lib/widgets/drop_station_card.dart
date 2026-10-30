import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/widgets/capacity_style.dart';
import 'package:mobile_apps_recan/widgets/circular_gauge.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';
import 'package:mobile_apps_recan/widgets/station_status_badge.dart';

class DropStationCard extends StatelessWidget {
  const new({required this.station, super.key});

  final DropStation station;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = station.capacityPercentage.clamp(0, 100);
    final distance = station.distanceLabel;
    final address = distance == null
        ? station.location
        : '${station.location} · $distance';

    return ReCanCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StationStatusBadge(full: station.isFull),
                const SizedBox(height: 8),
                Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircularGauge(
            percent: percent,
            color: CapacityStyle.colorFor(percent),
          ),
        ],
      ),
    );
  }
}
