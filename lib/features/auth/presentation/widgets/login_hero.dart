import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_rings.dart';

/// Navy header of the sign-in screen: brand mark and one line of purpose.
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
          colors: AppColors.heroGradient,
        ),
      ),
      child: BrandRings(child: child),
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
