import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_shadows.dart';

class PromoBanner {
  const new({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Color foreground;
  final VoidCallback onTap;
}

class PromoBannerCarousel extends StatefulWidget {
  const new({required this.banners, super.key});

  static const double height = 144;
  static const int virtualItemCount = 60;
  static const int virtualStartPage = 30;
  static const int recenterEdge = 5;
  static const Duration autoSlideInterval = Duration(seconds: 4);
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
    _timer = Timer.periodic(PromoBannerCarousel.autoSlideInterval, (_) {
      _advance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (!_controller.hasClients || _bannerCount == 0) return;
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
                  child: _BannerCard(banner: widget.banners[i % _bannerCount]),
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

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: PromoBannerCarousel.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner.colors,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: banner.onTap,
          child: Stack(
            children: [
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  banner.icon,
                  size: 112,
                  color: banner.foreground.withValues(alpha: 0.18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        color: banner.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: banner.foreground.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
