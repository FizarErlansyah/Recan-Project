import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';

/// Forest header of the sign-in screen: brand mark and one line of purpose.
class LoginHero extends StatelessWidget {
  const new({required this.overlap, super.key});

  /// How far the panel below covers this header, so the content is centred in
  /// what stays visible.
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    // Light status bar icons, since the header bleeds behind the status bar.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: _Backdrop(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, topInset + 24, 24, overlap + 24),
          child: const _Lockup(),
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: CustomPaint(painter: const _LoopPainter(), child: child),
    );
  }
}

class _Lockup extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const BrandHero(size: 72),
        const SizedBox(height: 12),
        Text(
          'ReCan',
          style: textTheme.headlineSmall?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'Setor kaleng, kumpulkan poin, jaga bumi.',
            'Drop cans, earn points, keep the earth clean.',
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.primarySoft),
        ),
      ],
    );
  }
}

/// Two open rings in the corner, a quiet nod to the loop a can travels.
class _LoopPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width, 0);
    for (final (radius, alpha) in [(110.0, 0.14), (170.0, 0.08)]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        1.75,
        2.2,
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
  bool shouldRepaint(_LoopPainter oldDelegate) => false;
}
