import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/login_page.dart';
import 'package:mobile_apps_recan/pages/onboarding_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/onboarding_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';

class SplashPage extends StatefulWidget {
  const new({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(seconds: 2);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.6,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_launch());
  }

  Future<void> _launch() async {
    final animation = _controller.forward();
    final hasToken = await AuthService.loadToken();
    final onboardingDone = await OnboardingService.isCompleted();
    await animation;
    if (!mounted) return;

    final Widget destination;
    if (!onboardingDone) {
      destination = const OnboardingPage();
    } else if (hasToken) {
      destination = const HomePage();
    } else {
      destination = const LoginPage();
    }
    Navigator.of(context)
        .pushReplacement(FadePageRoute<void>(page: destination));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ReCan',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                  ),
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
        ),
      ),
    );
  }
}
