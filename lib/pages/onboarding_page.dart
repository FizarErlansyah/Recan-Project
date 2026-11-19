import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/services/onboarding_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static List<OnboardingSlideData> get _slides => [
    OnboardingSlideData(
      titleLead: tr('Daur Ulang ', 'Recycle Your '),
      titleHighlight: tr('Sampah', 'Waste'),
      titleTail: tr(' Bekasmu', ' Material'),
      description: tr(
        'Setor kaleng bekasmu ke station terdekat dan ubah kebiasaan kecil menjadi kampus yang lebih bersih.',
        'Drop your used cans at the nearest station and turn small '
            'habits into a cleaner campus.',
      ),
      imageAsset: 'assets/images/ilustrasi_1.png',
      fallbackIcon: AppIcons.recycle,
    ),
    OnboardingSlideData(
      titleLead: tr('', 'Your '),
      titleHighlight: tr('Dasbor', 'Dashboard'),
      titleTail: '',
      description: tr(
        'Pantau setoran, streak, dan dampak karbonmu dalam satu tempat.',
        'Track your deposits, streaks and carbon savings, all in one '
            'place.',
      ),
      imageAsset: 'assets/images/ilustrasi_2.png',
      fallbackIcon: AppIcons.dashboard,
    ),
    OnboardingSlideData(
      titleLead: tr('Tukarkan ', 'Redeem your '),
      titleHighlight: tr('Poin', 'Points'),
      titleTail: '',
      description: tr(
        'Tukarkan poin yang kamu kumpulkan dengan kriya daur ulang dan hadiah e-wallet.',
        'Exchange the points you earn for upcycled crafts and '
            'e-wallet rewards.',
      ),
      imageAsset: 'assets/images/ilustrasi_3.png',
      fallbackIcon: AppIcons.gift,
    ),
  ];

  static const Duration _pageDuration = Duration(milliseconds: 450);

  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    await OnboardingService.markCompleted();
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(FadePageRoute<void>(page: const LoginPage()));
  }

  void _next() {
    if (_isLast) {
      unawaited(_finish());
      return;
    }
    _controller.nextPage(duration: _pageDuration, curve: Curves.easeOutCubic);
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.sandSoft,
              AppColors.primarySoft,
              AppColors.background,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isLast ? 0 : 1,
                    child: TextButton(
                      onPressed: _isLast ? null : _finish,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        tr('Lewati', 'Skip'),
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() {
                    _index = value;
                  }),
                  itemBuilder: (_, index) => OnboardingSlide(
                    data: _slides[index],
                    index: index,
                    controller: _controller,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    _Dot(active: i == _index),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(56),
                      shape: const StadiumBorder(),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _isLast
                            ? tr('Mulai', 'Get Started')
                            : tr('Lanjut', 'Next'),
                        key: ValueKey(_isLast),
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
