import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/services/onboarding_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
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
        'Setor kaleng bekasmu ke station terdekat dan ubah kebiasaan kecil menjadi lingkungan yang lebih bersih.',
        'Drop your used cans at the nearest station and turn small '
            'habits into a cleaner community.',
      ),
      imageAsset: 'assets/images/ilustrasi_1.png',
      fallbackIcon: AppIcons.recycle,
    ),
    OnboardingSlideData(
      titleLead: tr('', 'Your '),
      titleHighlight: tr('Dasbor', 'Dashboard'),
      titleTail: '',
      description: tr(
        'Pantau setoran, misi, dan dampak karbonmu dalam satu tempat.',
        'Track your deposits, missions and carbon savings, all in one '
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
        .pushReplacement(RecanPageRoute<void>(page: const LoginPage()));
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
    return Scaffold(
      body: _Backdrop(
        child: Column(
          children: [
            _SkipButton(onSkip: _isLast ? null : _finish),
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
            _Dots(count: _slides.length, current: _index),
            const SizedBox(height: 24),
            _NextButton(isLast: _isLast, onNext: _next),
          ],
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
    final palette = context.palette;
    // The light stops are fixed pastels; in dark mode the palette text turns
    // pale, so the same stops would leave the headline unreadable.
    final colors = context.isDark
        ? [palette.tint, palette.surface, palette.background]
        : [AppColors.sandSoft, AppColors.primarySoft, palette.background];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0, 0.55, 1],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const new({required this.onSkip});

  /// Null on the last slide, where the button fades away.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onSkip == null ? 0 : 1,
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: context.palette.textSecondary,
          ),
          child: Text(
            tr('Lewati', 'Skip'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const new({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (var i = 0; i < count; i++) _Dot(active: i == current)],
    );
  }
}

class _NextButton extends StatelessWidget {
  const new({required this.isLast, required this.onNext});

  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: FilledButton(
        onPressed: onNext,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
        ),
        child: _NextLabel(isLast: isLast),
      ),
    );
  }
}

class _NextLabel extends StatelessWidget {
  const new({required this.isLast});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        isLast ? tr('Mulai', 'Get Started') : tr('Lanjut', 'Next'),
        key: ValueKey(isLast),
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: context.palette.onPrimary),
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
        color: active ? context.palette.accent : context.palette.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
