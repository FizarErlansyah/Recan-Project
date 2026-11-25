import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/utils/weight_format.dart';
import 'package:mobile_apps_recan/widgets/ai_ask_pill.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/count_up.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';
import 'package:mobile_apps_recan/widgets/pull_up_overlap.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class HomeHeroHeader extends StatelessWidget {
  const new({
    required this.user,
    required this.cansDeposited,
    required this.onAskAi,
    required this.onScan,
    required this.onOpenProfile,
    super.key,
  });

  final UserProfile user;
  final int cansDeposited;
  final VoidCallback onAskAi;
  final VoidCallback onScan;
  final VoidCallback onOpenProfile;

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
    return Column(
      children: [
        _GreetingBand(
          child: StaggeredEntrance(
            child: _GreetingRow(
              user: user,
              today: _formatToday(),
              onOpenProfile: onOpenProfile,
              onAskAi: onAskAi,
            ),
          ),
        ),
        PullUpOverlap(
          extent: _overlap,
          child: _BalanceSection(
            points: user.pointsBalance,
            cans: cansDeposited,
            onScan: onScan,
          ),
        ),
      ],
    );
  }
}

class _GreetingBand extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const depth = HomeHeroHeader._curveDepth;

    return StatusBarIcons(
      light: true,
      child: ClipPath(
        clipper: const _CurvedBottomClipper(depth: depth),
        child: Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.fromLTRB(
            24,
            topInset + 16,
            24,
            depth + HomeHeroHeader._greenExtraHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const new({required this.points, required this.cans, required this.onScan});

  final int points;
  final int cans;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _BalanceCard(points: points, cans: cans, onScan: onScan),
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const new({
    required this.user,
    required this.today,
    required this.onOpenProfile,
    required this.onAskAi,
  });

  final UserProfile user;
  final String today;
  final VoidCallback onOpenProfile;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.trim().split(' ').first;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _HeaderAvatar(user: user, onTap: onOpenProfile),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                today,
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
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const new({required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  static const double _size = 42;

  @override
  Widget build(BuildContext context) {
    // The header is Yale Blue, so a Yale Blue disc would vanish: the fallback
    // initials sit on Pearl Aqua and the rim stays a quiet silver.
    return Semantics(
      button: true,
      label: tr('Buka profil', 'Open profile'),
      child: Pressable(
        haptic: PressHaptic.light,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // Padding below and to the right lifts the touch target towards 48dp
          // without moving the avatar off the 24dp content edge.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 3, 12, 3),
            child: ProfileAvatar(
              initials: user.initials,
              avatar: user.avatar,
              size: _size,
              color: AppColors.primarySoft,
              foreground: AppColors.primary,
              borderColor: AppColors.silverLight.withValues(alpha: 0.7),
              borderWidth: 1.5,
            ),
          ),
        ),
      ),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BalanceLabel(),
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

class _BalanceLabel extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: AppColors.silverLight);

    return Row(
      children: [
        const BrandHero(size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(tr('Saldo Tersedia', 'Available Balance'), style: style),
        ),
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
        AnimatedCountUp(
          value: points,
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
    final weightGrams = cans * DropSessionSummary.gramsPerCan;
    final carbonKg = cans * DropSessionSummary.carbonKgPerCan;
    final valueStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(color: AppColors.white, fontWeight: FontWeight.w700);

    // Top-aligned so a label that wraps to two lines never lifts its icon
    // and value out of line with the neighbouring metrics.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedRecycle01),
            label: tr('Setoran Kaleng', 'Cans Deposited'),
            value: AnimatedCountUp(value: cans, style: valueStyle),
          ),
        ),
        const _SilverRule.vertical(),
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedWeightScale),
            label: tr('Berat', 'Weight'),
            value: CountUp(
              value: weightGrams.toDouble(),
              memoryKey: 'hero.weight',
              format: formatWeight,
              style: valueStyle,
            ),
          ),
        ),
        const _SilverRule.vertical(),
        Expanded(
          child: _Metric(
            icon: hugeIcon(HugeIcons.strokeRoundedLeaf01),
            label: tr('Karbon Dicegah', 'Carbon Prevented'),
            value: CountUp(
              value: carbonKg,
              memoryKey: 'hero.carbon',
              format: CarbonLineChart.formatKg,
              style: valueStyle,
            ),
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
    return Tooltip(
      message: tr('Pindai QR', 'Scan QR'),
      child: BouncyTap(haptic: true, child: _ScanSurface(onTap: onTap)),
    );
  }
}

class _ScanSurface extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.silverLight.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: hugeIcon(HugeIcons.strokeRoundedQrCodeScan)(
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const new({required this.icon, required this.value, required this.label});

  final AppIconBuilder icon;
  final Widget value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        icon(color: AppColors.silverLight, size: 18),
        const SizedBox(height: 6),
        value,
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
