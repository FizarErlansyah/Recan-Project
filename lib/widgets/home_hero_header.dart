import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/ai_ask_pill.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/count_up.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';
import 'package:mobile_apps_recan/widgets/pull_up_overlap.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class HomeHeroHeader extends StatelessWidget {
  const new({
    required this.user,
    required this.cansDeposited,
    required this.onAskAi,
    required this.onScan,
    super.key,
  });

  final UserProfile user;
  final int cansDeposited;
  final VoidCallback onAskAi;
  final VoidCallback onScan;

  static const List<String> _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const List<String> _daysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const List<String> _monthsId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const List<String> _monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _formatToday() {
    final now = DateTime.now();
    final day = tr(_daysId[now.weekday - 1], _daysEn[now.weekday - 1]);
    final month = tr(_monthsId[now.month - 1], _monthsEn[now.month - 1]);
    return '$day, ${now.day} $month';
  }

  static const double _curveDepth = 32;
  static const double _greenExtraHeight = 56;
  static const double _overlap = 52;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final firstName = user.name.trim().split(' ').first;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        StatusBarIcons(
          light: true,
          child: ClipPath(
            clipper: const _CurvedBottomClipper(depth: _curveDepth),
            child: Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                24,
                topInset + 16,
                24,
                _curveDepth + _greenExtraHeight,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatToday(),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.78),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('Hai $firstName', 'Hi $firstName'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AiAskPill(onTap: onAskAi),
                ],
              ),
            ),
          ),
        ),
        PullUpOverlap(
          extent: _overlap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _BalanceCard(
              points: user.pointsBalance,
              cans: cansDeposited,
              onScan: onScan,
            ),
          ),
        ),
      ],
    );
  }
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  const new({required this.depth});

  final double depth;

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - depth)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + depth / 2,
        size.width,
        size.height - depth,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_CurvedBottomClipper oldClipper) =>
      oldClipper.depth != depth;
}

class _BalanceCard extends StatelessWidget {
  const new({required this.points, required this.cans, required this.onScan});

  final int points;
  final int cans;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return MetallicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BalanceRow(points: points, onScan: onScan),
          const SizedBox(height: 20),
          const _SilverRule.horizontal(),
          const SizedBox(height: 16),
          _MetricsRow(cans: cans),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const new({required this.points, required this.onScan});

  final int points;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Saldo Tersedia', 'Available Balance'),
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.silverLight,
                ),
              ),
              const SizedBox(height: 8),
              _PointsValue(points: points),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ScanButton(onTap: onScan),
      ],
    );
  }
}

class _PointsValue extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CountUp(
          value: points.toDouble(),
          memoryKey: 'hero.points',
          format: (value) => PointsHeader.formatNumber(value.round()),
          style: textTheme.displaySmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tr('Poin', 'Points'),
          style: textTheme.titleMedium?.copyWith(color: AppColors.goldLight),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const new({required this.cans});

  final int cans;

  @override
  Widget build(BuildContext context) {
    final weightKg = cans * DropSessionSummary.gramsPerCan / 1000;
    final carbonKg = cans * DropSessionSummary.carbonKgPerCan;

    // Top-aligned so a label that wraps to two lines never lifts its icon
    // and value out of line with the neighbouring metrics.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedRecycle01),
            target: cans.toDouble(),
            format: (value) => PointsHeader.formatNumber(value.round()),
            label: tr('Setoran Kaleng', 'Cans Deposited'),
            memoryKey: 'hero.cans',
          ),
        ),
        const _SilverRule.vertical(),
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedWeightScale),
            target: weightKg,
            format: (value) => '${CarbonLineChart.formatNumber(value)} kg',
            label: tr('Berat', 'Weight'),
            memoryKey: 'hero.weight',
          ),
        ),
        const _SilverRule.vertical(),
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedLeaf01),
            target: carbonKg,
            format: CarbonLineChart.formatKg,
            label: tr('Karbon Dicegah', 'Carbon Prevented'),
            memoryKey: 'hero.carbon',
          ),
        ),
      ],
    );
  }
}

class _SilverRule extends StatelessWidget {
  const new horizontal() : isVertical = false;
  const new vertical() : isVertical = true;

  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.silverLight.withValues(alpha: 0.22);
    if (!isVertical) return Container(height: 1, color: color);
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}

class _ScanButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      haptic: PressHaptic.light,
      child: Material(
        color: AppColors.primaryDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.silverLight.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: hugeIcon(HugeIcons.strokeRoundedQrCodeScan)(
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const new({
    required this.icon,
    required this.target,
    required this.format,
    required this.label,
    required this.memoryKey,
  });

  final AppIconBuilder icon;
  final double target;
  final String Function(double value) format;
  final String label;
  final String memoryKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        icon(color: AppColors.silverLight, size: 18),
        const SizedBox(height: 6),
        CountUp(
          value: target,
          memoryKey: memoryKey,
          format: format,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(color: AppColors.silverLight),
        ),
      ],
    );
  }
}
