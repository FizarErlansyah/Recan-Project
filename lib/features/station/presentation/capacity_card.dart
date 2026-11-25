import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// Room left in the station once the cans of this session are counted.
class CapacityCard extends StatelessWidget {
  const new({required this.station, required this.sessionCans, super.key});

  final ScannedStation station;
  final int sessionCans;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final room = (station.remaining - sessionCans).clamp(0, station.remaining);
    final used = (station.maxCapacity - room) / station.maxCapacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(
            'Sisa ruang: $room dari ${station.maxCapacity} kaleng',
            'Room left: $room of ${station.maxCapacity} cans',
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: used.clamp(0, 1).toDouble(),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          color: AppColors.primarySoft,
          backgroundColor: AppColors.white.withValues(alpha: 0.16),
        ),
        if (room == 0) ...[
          const SizedBox(height: 8),
          Text(
            tr(
              'Batas station tercapai. Selesaikan sesi ini.',
              'Station limit reached. Finish this session.',
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.goldLight),
          ),
        ],
      ],
    );
  }
}
