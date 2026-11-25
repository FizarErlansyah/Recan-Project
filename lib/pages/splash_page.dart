import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/onboarding_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/onboarding_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class SplashPage extends StatefulWidget {
  const new({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // With the route transition that follows, the whole greeting stays inside
  // 1.5 seconds.
  static const Duration _reveal = Duration(milliseconds: 1100);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _reveal,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_launch());
  }

  Future<void> _launch() async {
    final reveal = _controller.forward();
    final hasToken = await AuthService.restoreSession();
    final onboardingDone = await OnboardingService.isCompleted();
    await reveal;
    if (!mounted) return;

    final Widget destination;
    if (!onboardingDone) {
      destination = const OnboardingPage();
    } else if (hasToken) {
      destination = const HomePage();
    } else {
      destination = const LoginPage();
    }
    await Navigator.of(context)
        .pushReplacement(RecanPageRoute<void>(page: destination));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.forest,
        body: _SplashStage(
          animation: still ? kAlwaysCompleteAnimation : _controller,
        ),
      ),
    );
  }
}

class _SplashStage extends StatelessWidget {
  const new({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: Center(child: _SplashLockup(animation: animation)),
    );
  }
}

class _SplashLockup extends StatelessWidget {
  const new({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final pop = CurveTween(
      curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
    );
    final appear = CurveTween(curve: const Interval(0, 0.35));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: appear.animate(animation),
          child: ScaleTransition(
            scale: pop
                .animate(animation)
                .drive(Tween<double>(begin: 0.8, end: 1)),
            child: const BrandHero(size: 112),
          ),
        ),
        const SizedBox(height: 24),
        _SplashWords(animation: animation),
      ],
    );
  }
}

class _SplashWords extends StatelessWidget {
  const new({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settle = CurveTween(
      curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
    ).animate(animation);

    return FadeTransition(
      opacity: settle,
      child: SlideTransition(
        position: settle.drive(
          Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero),
        ),
        child: Column(
          children: [
            Text(
              'ReCan',
              style: textTheme.headlineMedium?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              tr('Daur Ulang Kalengmu', 'Recycle Your Can'),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primarySoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
