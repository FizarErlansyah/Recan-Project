import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/services/analytics_service.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/carbon_metric_cards.dart';
import 'package:mobile_apps_recan/widgets/carbon_range_chips.dart';
import 'package:mobile_apps_recan/widgets/shimmer.dart';

class CarbonAnalyticsSection extends StatefulWidget {
  const new({required this.onUnauthorized, super.key});

  final VoidCallback onUnauthorized;

  @override
  State<CarbonAnalyticsSection> createState() => _CarbonAnalyticsSectionState();
}

class _CarbonAnalyticsSectionState extends State<CarbonAnalyticsSection> {
  CarbonRange _range = CarbonRange.week;
  late Future<CarbonImpact> _future = AnalyticsService.fetchCarbonImpact(
    _range,
  );

  @override
  void initState() {
    super.initState();
    DataRefresh.revision.addListener(_reload);
  }

  @override
  void dispose() {
    DataRefresh.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = AnalyticsService.fetchCarbonImpact(_range);
    });
  }

  void _selectRange(CarbonRange range) {
    if (range == _range) return;
    _range = range;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              'Dampak Karbon & Keberlanjutan',
              'Carbon & Sustainability Impact',
            ),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(_range.subtitle, style: textTheme.bodySmall),
          const SizedBox(height: 8),
          CarbonRangeChips(selected: _range, onSelected: _selectRange),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: FutureBuilder<CarbonImpact>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _ChartSkeleton();
                }
                final error = snapshot.error;
                if (error != null) {
                  return _ChartCard(child: _errorMessage(error));
                }
                final impact = snapshot.data;
                if (impact == null || impact.points.isEmpty) {
                  return _ChartCard(
                    child: _ChartMessage(
                      message: tr(
                        'Belum ada data dampak karbon untuk rentang ini.',
                        'No carbon impact data for this range yet.',
                      ),
                    ),
                  );
                }
                return _ImpactContent(impact: impact);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorMessage(Object error) {
    final unauthorized = error is ApiException && error.unauthorized;
    return _ChartMessage(
      message: error is ApiException
          ? error.message
          : tr(
              'Terjadi kesalahan tak terduga.',
              'An unexpected error occurred.',
            ),
      actionLabel: unauthorized
          ? tr('Masuk Kembali', 'Sign In Again')
          : tr('Coba Lagi', 'Try Again'),
      onAction: unauthorized ? widget.onUnauthorized : _reload,
    );
  }
}

class _ImpactContent extends StatelessWidget {
  const new({required this.impact});

  final CarbonImpact impact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CarbonMetricCards(impact: impact),
        const SizedBox(height: 16),
        _ChartCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                impact.range.totalLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${CarbonLineChart.formatKg(impact.totalCarbonKg)} CO₂e',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: CarbonLineChart(
                  key: ValueKey(impact.range),
                  impact: impact,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.silverLight.withValues(alpha: 0.28),
        ),
      ),
      child: child,
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 128, radius: 16)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 128, radius: 16)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 128, radius: 16)),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: CarbonLineChart.height + 96, radius: 16),
        ],
      ),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const new({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = actionLabel;

    return SizedBox(
      width: double.infinity,
      height: CarbonLineChart.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hugeIcon(HugeIcons.strokeRoundedAnalyticsUp)(
            color: AppColors.silverLight,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
          if (label != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primarySoft,
                minimumSize: const Size(48, 48),
              ),
              child: Text(label),
            ),
          ],
        ],
      ),
    );
  }
}
