import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/morphing_submit_button.dart';

/// The server's answer, when it refused, and the submit button under it.
class AuthFormFooter extends StatelessWidget {
  const new({
    required this.label,
    required this.loading,
    required this.onSubmit,
    super.key,
    this.error,
  });

  final String label;
  final bool loading;
  final VoidCallback onSubmit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final message = error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: still ? Duration.zero : const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: message == null
              ? const SizedBox(height: 24)
              : _ErrorNote(key: ValueKey(message), message: message),
        ),
        MorphingSubmitButton(
          label: label,
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const new({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.palette.dangerSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _NoteLine(message: message),
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: context.palette.textPrimary);

    return Row(
      children: [
        HugeIcon(icon: AppIcons.info, size: 20, color: context.palette.danger),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: style)),
      ],
    );
  }
}
