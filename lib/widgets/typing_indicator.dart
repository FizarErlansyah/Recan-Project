import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/ai_avatar.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';

class TypingIndicator extends StatefulWidget {
  const new({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AiAvatar(),
          const SizedBox(width: 8),
          _Bubble(dots: _Dots(animation: _controller)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const new({required this.dots});

  final Widget dots;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [dots, const SizedBox(height: 8), const _Lines()],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const new({required this.animation});

  static const int _count = 3;
  static const double _bounceHeight = 6;

  final Animation<double> animation;

  double _offsetFor(int index) {
    final phase = (animation.value - index * 0.15) % 1.0;
    if (phase > 0.5) return 0;
    return -_bounceHeight * math.sin(phase * 2 * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Row(
          children: [
            for (var i = 0; i < _count; i++) ...[
              _Dot(offset: _offsetFor(i)),
              if (i < _count - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.offset});

  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: context.palette.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 8, radius: 4),
          SizedBox(height: 8),
          ShimmerBox(width: 88, height: 8, radius: 4),
        ],
      ),
    );
  }
}
