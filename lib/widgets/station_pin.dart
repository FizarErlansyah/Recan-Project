import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/map_station.dart';

class StationPin extends StatelessWidget {
  const new({required this.station, required this.onTap, super.key});

  final MapStation station;
  final VoidCallback onTap;

  static const double size = 48;

  @override
  Widget build(BuildContext context) {
    final fill = station.isAlmostFull
        ? AppColors.danger
        : AppColors.primarySoft;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: size,
            color: AppColors.primary,
            shadows: [
              Shadow(
                color: AppColors.shadowStrong,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.location_on_rounded, size: size - 6, color: fill),
          ),
        ],
      ),
    );
  }
}
