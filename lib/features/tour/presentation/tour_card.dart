import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/tour/domain/tour_step.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// The floating note of one tour step, with its way forward, back and out.
class TourCard extends StatelessWidget {
  const new({
    required this.step,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    super.key,
  });

  final TourStep step;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    // Large text scrolls inside the card instead of pushing it off screen.
    return Material(
      color: context.palette.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(AppDecorations.radius),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Heading(step: step, position: '${index + 1}/$total'),
            const SizedBox(height: 16),
            _Actions(
              isFirst: index == 0,
              isLast: index == total - 1,
              onNext: onNext,
              onBack: onBack,
              onSkip: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const new({required this.step, required this.position});

  final TourStep step;
  final String position;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          position,
          style: textTheme.labelMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(step.title, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(step.body, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const new({
    required this.isFirst,
    required this.isLast,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!isLast)
          TextButton(onPressed: onSkip, child: Text(tr('Lewati', 'Skip'))),
        if (!isFirst)
          OutlinedButton(onPressed: onBack, child: Text(tr('Kembali', 'Back'))),
        FilledButton(
          onPressed: onNext,
          child: Text(isLast ? tr('Mulai', 'Start') : tr('Lanjut', 'Next')),
        ),
      ],
    );
  }
}
