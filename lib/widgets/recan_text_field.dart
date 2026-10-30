import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class ReCanTextField extends StatelessWidget {
  const new({
    required this.controller,
    required this.label,
    required this.icon,
    super.key,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: maxLines > 1 ? 2 : 1,
        maxLines: maxLines,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        style: textTheme.bodyMedium,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          alignLabelWithHint: maxLines > 1,
          labelStyle: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.silver),
          prefixIcon: Icon(icon, color: AppColors.primary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
