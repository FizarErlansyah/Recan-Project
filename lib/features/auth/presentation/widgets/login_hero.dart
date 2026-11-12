import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';

class LoginHero extends StatelessWidget {
  const new({super.key});

  // Sheet overlaps the hero bottom, so the logo is lifted by half that
  // overlap to stay optically centered in the visible green area.
  static const double _logoLift = 16;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    // Light status bar icons, since the hero bleeds behind the status bar.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.primary,
        child: Stack(
          children: [
            const Positioned(top: -90, right: -70, child: _Orb(size: 260)),
            const Positioned(bottom: -40, left: -100, child: _Orb(size: 220)),
            const Positioned(top: 40, left: 36, child: _Orb(size: 72)),
            Padding(
              padding: EdgeInsets.only(top: topInset, bottom: _logoLift * 2),
              child: const Center(
                child: ReCanLogo(
                  size: 112,
                  asset: 'assets/images/recan_brandmak_white.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const new({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
