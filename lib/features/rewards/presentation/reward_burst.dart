import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';

/// The one big celebration: the points just earned pop up over the page with a
/// burst of rays, then leave on their own.
abstract final class RewardBurst {
  /// Does nothing under reduced motion; the snack bar already says it.
  static void show(BuildContext context, int points) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Burst(
        points: points,
        onDone: () => entry
          ..remove()
          ..dispose(),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _Burst extends StatefulWidget {
  const new({required this.points, required this.onDone})
    : super(key: const ValueKey('reward-burst'));

  final int points;
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  static const Duration _life = Duration(milliseconds: 1600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _life,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward().whenComplete(widget.onDone));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: _Stage(
        animation: _controller,
        child: Semantics(
          liveRegion: true,
          child: _Medal(points: widget.points),
        ),
      ),
    );
  }
}

/// Pops the medal in, throws the rays and fades the whole thing out.
class _Stage extends StatelessWidget {
  const new({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  static final Animatable<double> _fade = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 12),
    TweenSequenceItem(tween: ConstantTween(1), weight: 66),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 22),
  ]);
  static final Animatable<double> _pop = Tween<double>(
    begin: 0.6,
    end: 1,
  ).chain(CurveTween(curve: const Interval(0, 0.4, curve: Curves.easeOutBack)));
  static final Animatable<double> _rays = CurveTween(
    curve: const Interval(0.05, 0.6, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final color = context.palette.warm;

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, medal) => Opacity(
        opacity: _fade.evaluate(animation),
        child: CustomPaint(
          painter: _RayPainter(_rays.evaluate(animation), color),
          child: Center(
            child: Transform.scale(
              scale: _pop.evaluate(animation),
              child: medal,
            ),
          ),
        ),
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.warm,
      elevation: 8,
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _MedalRow(points: points),
      ),
    );
  }
}

class _MedalRow extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.onWarm;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: AppIcons.coins, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          '+${formatPoints(points)}',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _RayPainter extends CustomPainter {
  const new(this.progress, this.color);

  static const int _count = 12;

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final inner = 90 + 90 * progress;
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _count; i++) {
      final direction = Offset.fromDirection(math.pi * 2 * i / _count);
      canvas.drawLine(
        center + direction * inner,
        center + direction * (inner + 24 * (1 - progress)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RayPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
