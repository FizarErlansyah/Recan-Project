import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';

class PromoBanner {
  const new({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final AppIconBuilder icon;
  final List<Color> colors;
  final VoidCallback onTap;
}

class PromoBannerCarousel extends StatefulWidget {
  const new({required this.banners, super.key});

  static const double height = 184;
  static const int virtualItemCount = 60;
  static const int virtualStartPage = 30;
  static const int recenterEdge = 5;
  static const Duration autoSlideInterval = Duration(seconds: 6);
  static const Duration slideDuration = Duration(milliseconds: 600);

  final List<PromoBanner> banners;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.92,
    initialPage: _startPage,
  );
  Timer? _timer;
  int _index = 0;

  int get _bannerCount => widget.banners.length;

  int get _startPage => _bannerCount == 0
      ? 0
      : PromoBannerCarousel.virtualStartPage -
            PromoBannerCarousel.virtualStartPage % _bannerCount;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Restarting on release gives the reader a full interval before the next
  // slide moves under their thumb.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(PromoBannerCarousel.autoSlideInterval, (_) {
      _advance();
    });
  }

  void _pauseTimer() => _timer?.cancel();

  void _advance() {
    if (!_controller.hasClients || _bannerCount == 0) return;
    if (!TickerMode.valuesOf(context).enabled) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.nextPage(
      duration: PromoBannerCarousel.slideDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _recenterIfNearEdge() {
    if (!mounted || !_controller.hasClients || _bannerCount == 0) return;
    if (_controller.position.isScrollingNotifier.value) return;
    final page = _controller.page?.round() ?? _startPage;
    final nearEdge =
        page <= PromoBannerCarousel.recenterEdge ||
        page >=
            PromoBannerCarousel.virtualItemCount -
                PromoBannerCarousel.recenterEdge;
    if (!nearEdge) return;
    _controller.jumpToPage(_startPage + page % _bannerCount);
  }

  void _handlePageChanged(int page) {
    setState(() => _index = page % _bannerCount);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recenterIfNearEdge());
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerCount == 0) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: PromoBannerCarousel.height + 24,
          child: RepaintBoundary(
            child: Listener(
              onPointerDown: (_) => _pauseTimer(),
              onPointerUp: (_) => _startTimer(),
              onPointerCancel: (_) => _startTimer(),
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _recenterIfNearEdge();
                  return false;
                },
                child: PageView.builder(
                  controller: _controller,
                  clipBehavior: Clip.none,
                  itemCount: PromoBannerCarousel.virtualItemCount,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 24),
                    child: _BannerCard(
                      banner: widget.banners[i % _bannerCount],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _bannerCount; i++)
              _BannerDot(active: i == _index),
          ],
        ),
      ],
    );
  }
}

class _BannerDot extends StatelessWidget {
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

class _BannerCard extends StatelessWidget {
  const new({required this.banner});

  static const double _watermarkSize = 148;

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PromoBannerCarousel.height,
      child: MetallicCard(
        radius: 16,
        colors: banner.colors,
        onTap: banner.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -28,
              top: -20,
              child: Transform.rotate(
                angle: -0.18,
                child: banner.icon(
                  color: AppColors.white.withValues(alpha: 0.10),
                  size: _watermarkSize,
                ),
              ),
            ),
            _BannerText(banner: banner),
          ],
        ),
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const new({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          banner.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          banner.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.silverLight),
        ),
      ],
    );
  }
}
