import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

/// Slides a slim balance bar over [child] once its list has scrolled past the
/// header, so the balance and the scanner stay one tap away.
class CompactBalanceBar extends StatefulWidget {
  const new({
    required this.points,
    required this.onScan,
    required this.child,
    super.key,
  });

  final int points;
  final VoidCallback onScan;
  final Widget child;

  @override
  State<CompactBalanceBar> createState() => _CompactBalanceBarState();
}

class _CompactBalanceBarState extends State<CompactBalanceBar> {
  static const double _threshold = 240;
  static const Duration _slide = Duration(milliseconds: 220);

  bool _collapsed = false;

  bool _track(ScrollNotification notification) {
    // Only the page itself counts, not the carousels inside it.
    if (notification.depth != 0) return false;
    final collapsed = notification.metrics.pixels > _threshold;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final bar = _collapsed
        ? _Bar(points: widget.points, onScan: widget.onScan)
        : const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: _track,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: still ? Duration.zero : _slide,
              transitionBuilder: _dropIn,
              child: bar,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dropIn(Widget child, Animation<double> animation) =>
      SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, -1), end: Offset.zero),
        ),
        child: child,
      );
}

class _Bar extends StatelessWidget {
  const new({required this.points, required this.onScan})
    : super(key: const ValueKey('home-compact-bar'));

  final int points;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return StatusBarIcons(
      light: true,
      child: DecoratedBox(
        decoration: AppDecorations.hero(radius: 0),
        child: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.fromLTRB(24, 8, 12, 8),
          child: _BarRow(points: points, onScan: onScan),
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const new({required this.points, required this.onScan});

  final int points;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: AppColors.white);

    return Row(
      children: [
        const ReCanLogo(size: 24, asset: 'assets/images/recan_mark_white.png'),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            formatPoints(points),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        IconButton(
          onPressed: onScan,
          tooltip: tr('Pindai QR', 'Scan QR'),
          icon: const HugeIcon(icon: AppIcons.qr, color: AppColors.white),
        ),
      ],
    );
  }
}
