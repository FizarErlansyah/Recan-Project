import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class GradientPillButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = onPressed != null && !loading;

    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        label,
                        key: const ValueKey('label'),
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
