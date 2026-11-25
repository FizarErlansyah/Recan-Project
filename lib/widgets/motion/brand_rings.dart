import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Two open rings, a quiet nod to the loop a can travels. They are drawn up to
/// [progress], so the splash can trace them and a header can show them whole.
class BrandRings extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.progress = 1,
    this.anchor = Alignment.topRight,
  });

  final Widget child;

  /// 0 draws nothing, 1 the full sweep.
  final double progress;
  final Alignment anchor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(progress: progress, anchor: anchor),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  const new({required this.progress, required this.anchor});

  static const double _start = 1.75;
  static const double _sweep = 4.4;

  final double progress;
  final Alignment anchor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = anchor.alongSize(size);
    for (final (radius, alpha) in [(110.0, 0.14), (170.0, 0.08)]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _start,
        _sweep * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primarySoft.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.anchor != anchor;
}
