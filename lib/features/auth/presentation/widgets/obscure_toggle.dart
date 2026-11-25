import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class ObscureToggle extends StatelessWidget {
  const new({required this.obscure, required this.onPressed, super.key});

  final bool obscure;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: obscure
          ? tr('Tampilkan kata sandi', 'Show password')
          : tr('Sembunyikan kata sandi', 'Hide password'),
      icon: HugeIcon(
        icon: obscure ? AppIcons.hidden : AppIcons.visible,
        size: 20,
        color: context.palette.textSecondary,
      ),
      onPressed: onPressed,
    );
  }
}
