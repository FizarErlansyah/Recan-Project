import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/tutorial/domain/can_tutorial.dart';
import 'package:mobile_apps_recan/widgets/can_placeholder.dart';

class TutorialStepView extends StatelessWidget {
  const new({required this.step, required this.number, super.key});

  final TutorialStep step;
  final int number;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final safety = step.safety;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _Illustration(step: step, number: number),
        const SizedBox(height: 20),
        Text(step.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(step.body, style: textTheme.bodyLarge),
        if (safety != null) ...[
          const SizedBox(height: 16),
          _SafetyNote(text: safety),
        ],
      ],
    );
  }
}

/// The can being worked on, with the tool of the step in the corner.
class _Illustration extends StatelessWidget {
  const new({required this.step, required this.number});

  final TutorialStep step;
  final int number;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CanPlaceholder(seed: number, art: step.art),
            Positioned(
              right: 12,
              bottom: 12,
              child: _ToolBadge(icon: step.icon),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolBadge extends StatelessWidget {
  const new({required this.icon});

  final IconGlyph icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.palette.primary,
      ),
      child: HugeIcon(icon: icon, color: context.palette.onPrimary, size: 28),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.goldText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.goldSoft,
        borderRadius: BorderRadius.circular(AppDecorations.controlRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: AppIcons.warning, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
