import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

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
  final IconGlyph fallbackIcon;
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = _offset();
        final visibility = (1 - offset.abs()).clamp(0.0, 1.0);

        return Opacity(
          opacity: visibility,
          // Centred while it fits, scrollable once large text does not.
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _SlideBody(data: data, offset: offset),
            ),
          ),
        );
      },
    );
  }
}

/// Title, description and picture, each drifting at its own speed.
class _SlideBody extends StatelessWidget {
  const new({required this.data, required this.offset});

  final OnboardingSlideData data;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(offset * 40, 0),
          child: _Title(data: data),
        ),
        const SizedBox(height: 16),
        Transform.translate(
          offset: Offset(offset * 60, 0),
          child: _Description(text: data.description),
        ),
        const SizedBox(height: 32),
        Align(
          child: Transform.translate(
            offset: Offset(offset * 140, 0),
            child: _Illustration(data: data),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const new({required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: data.titleLead),
          TextSpan(
            text: data.titleHighlight,
            style: TextStyle(color: context.palette.accent),
          ),
          TextSpan(text: data.titleTail),
        ],
      ),
      style: Theme.of(context).textTheme.displaySmall,
    );
  }
}

class _Description extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: context.palette.textSecondary, height: 1.5),
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
          decoration: AppDecorations.card(context, radius: 32),
          child: Center(
            child: HugeIcon(
              icon: data.fallbackIcon,
              size: 96,
              color: context.palette.accent,
            ),
          ),
        ),
      ),
    );
  }
}
