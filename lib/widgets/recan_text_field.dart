import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/field_glyph.dart';

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
  final IconGlyph icon;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      minLines: maxLines > 1 ? 2 : 1,
      maxLines: maxLines,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: textTheme.bodyMedium,
      cursorColor: context.palette.accent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        alignLabelWithHint: maxLines > 1,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: context.palette.textSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.silver),
        prefixIcon: FieldGlyph(icon: icon, color: context.palette.accent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
