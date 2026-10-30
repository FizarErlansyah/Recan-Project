import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class CarbonLineChart extends StatelessWidget {
  const new({required this.impact, super.key});

  final CarbonImpact impact;

  static const double height = 200;
  static const int _denseThreshold = 8;
  static const int _denseLabelStep = 3;

  static String formatNumber(double value) => value < 100
      ? value.toStringAsFixed(1).replaceAll('.', ',')
      : PointsHeader.formatNumber(value.round());

  static String formatKg(double value) => '${formatNumber(value)} kg';

  List<CarbonPoint> get _points => impact.points;

  double get _maxY {
    final peak = _points.fold<double>(
      0,
      (max, point) => math.max(max, point.carbonKg),
    );
    return peak <= 0 ? 1 : peak * 1.3;
  }

  int get _labelStep => _points.length > _denseThreshold ? _denseLabelStep : 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spots = [
      for (var i = 0; i < _points.length; i++)
        FlSpot(i.toDouble(), _points[i].carbonKg),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        LineChartData(
          minX: 0,
          maxX: math.max(_points.length - 1, 1).toDouble(),
          minY: 0,
          maxY: _maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (value != index ||
                      index < 0 ||
                      index >= _points.length ||
                      index % _labelStep != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 12,
                    child: Text(
                      _points[index].label,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.silver,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              tooltipBorderRadius: BorderRadius.circular(12),
              tooltipBorder: const BorderSide(color: AppColors.primarySoft),
              fitInsideHorizontally: true,
              getTooltipItems: (touchedSpots) => [
                for (final spot in touchedSpots)
                  LineTooltipItem(
                    '${_points[spot.x.toInt()].label}\n'
                    '${formatKg(spot.y)} CO₂e',
                    textTheme.labelLarge?.copyWith(color: AppColors.white) ??
                        const TextStyle(),
                  ),
              ],
            ),
            getTouchedSpotIndicator: (barData, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(
                    color: AppColors.primarySoft.withValues(alpha: 0.4),
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: AppColors.primarySoft,
                          strokeWidth: 3,
                          strokeColor: AppColors.primary,
                        ),
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              isStrokeCapRound: true,
              barWidth: 4,
              color: AppColors.primarySoft,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primarySoft.withValues(alpha: 0.4),
                    AppColors.textPrimary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
