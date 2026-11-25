import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

/// A full-width submit button that draws itself into a round spinner while the
/// request runs, and opens up again if it fails.
class MorphingSubmitButton extends StatelessWidget {
  const new({
    required this.label,
    required this.loading,
    required this.onPressed,
    super.key,
  });

  static const double height = 52;
  static const Duration _morph = Duration(milliseconds: 280);

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : _morph;

    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: AnimatedContainer(
          key: const ValueKey('auth-submit'),
          duration: duration,
          curve: Curves.easeInOutCubic,
          width: loading ? height : constraints.maxWidth,
          height: height,
          child: _Face(
            label: label,
            loading: loading,
            onPressed: onPressed,
            duration: duration,
          ),
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const new({
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.duration,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    const round = MorphingSubmitButton.height / 2;

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        disabledBackgroundColor: context.palette.primary,
        disabledForegroundColor: context.palette.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(loading ? round : 16),
        ),
      ),
      child: AnimatedSwitcher(
        duration: duration,
        child: loading
            ? _Spinner(still: MediaQuery.disableAnimationsOf(context))
            : Text(label, maxLines: 1, softWrap: false),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const new({required this.still});

  final bool still;

  @override
  Widget build(BuildContext context) {
    // A fixed arc under reduced motion; the endless sweep never settles.
    return SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(
        value: still ? 0.7 : null,
        strokeWidth: 2.5,
        color: context.palette.onPrimary,
      ),
    );
  }
}
