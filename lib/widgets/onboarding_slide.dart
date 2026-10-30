import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class OnboardingSlideData {
  const new({
    required this.titleLead,
    required this.titleHighlight,
    required this.titleTail,
    required this.description,
    required this.imageAsset,
    required this.fallbackIcon,
  });

  final String titleLead;
  final String titleHighlight;
  final String titleTail;
  final String description;
  final String imageAsset;
  final IconData fallbackIcon;
}

class OnboardingSlide extends StatelessWidget {
  const new({
    required this.data,
    required this.index,
    required this.controller,
    super.key,
  });

  static const double _illustrationSize = 240;

  final OnboardingSlideData data;
  final int index;
  final PageController controller;

  double _offset() {
    if (!controller.hasClients || !controller.position.haveDimensions) {
      return controller.initialPage - index.toDouble();
    }
    return (controller.page ?? controller.initialPage.toDouble()) - index;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = _offset();
        final visibility = (1 - offset.abs()).clamp(0.0, 1.0);

        return Opacity(
          opacity: visibility,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(offset * 40, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: data.titleLead),
                        TextSpan(
                          text: data.titleHighlight,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: data.titleTail),
                      ],
                    ),
                    style: textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Transform.translate(
                  offset: Offset(offset * 60, 0),
                  child: Text(
                    data.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  child: Transform.translate(
                    offset: Offset(offset * 140, 0),
                    child: _Illustration(data: data),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Illustration extends StatelessWidget {
  const new({required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: OnboardingSlide._illustrationSize,
      height: OnboardingSlide._illustrationSize,
      child: Image.asset(
        data.imageAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(data.fallbackIcon, size: 96, color: AppColors.primary),
        ),
      ),
    );
  }
}
