import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/utils/weight_format.dart';
import 'package:mobile_apps_recan/widgets/ai_ask_pill.dart';
import 'package:mobile_apps_recan/widgets/brushed_metal.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/count_up.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';
import 'package:mobile_apps_recan/widgets/motion/balance_hero.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/motion/rolling_number.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';
import 'package:mobile_apps_recan/widgets/pull_up_overlap.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class HomeHeroHeader extends StatelessWidget {
  const new({
    required this.user,
    required this.cansDeposited,
    required this.onAskAi,
    required this.onScan,
    required this.onOpenProfile,
    super.key,
    this.cardAnchor,
  });

  final UserProfile user;
  final int cansDeposited;
  final VoidCallback onAskAi;
  final VoidCallback onScan;
  final VoidCallback onOpenProfile;

  /// Marks the balance card for something that needs to find it on screen.
  final Key? cardAnchor;

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
  static const double _bandExtraHeight = 36;
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
            cardAnchor: cardAnchor,
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
          decoration: AppDecorations.hero(radius: 0),
          padding: EdgeInsets.fromLTRB(
            24,
            topInset + 16,
            24,
            depth + HomeHeroHeader._bandExtraHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const new({
    required this.points,
    required this.cans,
    required this.onScan,
    required this.cardAnchor,
  });

  final int points;
  final int cans;
  final VoidCallback onScan;
  final Key? cardAnchor;

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: KeyedSubtree(
          key: cardAnchor,
          child: _BalanceCard(points: points, cans: cans, onScan: onScan),
        ),
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
                style: textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // The pill has a fixed height, so its label stops growing before it
        // pushes the greeting off the row.
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: AiAskPill(onTap: onAskAi),
        ),
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
    // A metal card on the navy band is the one focal point of the screen, and
    // where the splash plate lands.
    return BalanceHero(
      child: BrushedMetal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceRow(points: points, onScan: onScan),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _MetricsRow(cans: cans),
          ],
        ),
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
        ?.copyWith(color: context.palette.textSecondary);

    return Row(
      children: [
        const _BrandDisc(),
        const SizedBox(width: 8),
        Flexible(
          child: Text(tr('Saldo Tersedia', 'Available Balance'), style: style),
        ),
      ],
    );
  }
}

/// The white mark needs a navy ground on a light card.
class _BrandDisc extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: const ReCanLogo(size: 18, asset: BrandHero.asset),
    );
  }
}

class _PointsValue extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayMedium
        ?.copyWith(color: context.palette.textPrimary);

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RollingNumber(value: points, style: style),
        ),
        const _PointsUnit(),
      ],
    );
  }
}

class _PointsUnit extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: context.palette.warm,
        shape: const StadiumBorder(),
      ),
      child: Text(
        tr('Poin', 'Points'),
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: context.palette.onWarm),
      ),
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
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: context.palette.textPrimary,
      fontWeight: FontWeight.w700,
    );

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
        const _MetricRule(),
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
        const _MetricRule(),
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

class _MetricRule extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      // The border tone vanishes where the reflection crosses the card.
      color: context.palette.textSecondary.withValues(alpha: 0.25),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: const ValueKey('hero-scan'),
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
      color: context.palette.primary,
      elevation: 4,
      shadowColor: AppColors.shadowStrong,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: const _ScanFace()),
    );
  }
}

/// The only scan action on Beranda, so it says what it does.
class _ScanFace extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final color = context.palette.onPrimary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hugeIcon(HugeIcons.strokeRoundedQrCodeScan)(color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              tr('Pindai', 'Scan'),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
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
        icon(color: context.palette.accent, size: 20),
        const SizedBox(height: 6),
        value,
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
