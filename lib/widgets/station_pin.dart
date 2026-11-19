import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/map_station.dart';

class StationPin extends StatelessWidget {
  const new({required this.station, required this.onTap, super.key});

  final MapStation station;
  final VoidCallback onTap;

  static const double size = 48;

  @override
  Widget build(BuildContext context) {
    final color = station.isAlmostFull ? AppColors.danger : AppColors.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: HugeIcon(icon: AppIcons.location, size: size, color: color),
    );
  }
}
