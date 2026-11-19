import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/theme_preference.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class SettingsSheets {
  const new _();

  static const String appVersion = '1.0.0';

  static Future<void> showLanguage(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Pilih Bahasa', 'Choose Language'),
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _LanguageRow(
                  label: 'Bahasa Indonesia',
                  selected: !MockStore.isEnglish.value,
                  onTap: () => _selectLanguage(sheetContext, false),
                ),
                _LanguageRow(
                  label: 'English',
                  selected: MockStore.isEnglish.value,
                  onTap: () => _selectLanguage(sheetContext, true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _selectLanguage(BuildContext sheetContext, bool english) {
    MockStore.isEnglish.value = english;
    Navigator.of(sheetContext).pop();
  }

  static Future<void> showAppearance(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        final options = <(ThemeMode, String)>[
          (ThemeMode.system, tr('Ikuti Sistem', 'Follow System')),
          (ThemeMode.light, tr('Terang', 'Light')),
          (ThemeMode.dark, tr('Gelap', 'Dark')),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Tampilan', 'Appearance'), style: textTheme.titleLarge),
                const SizedBox(height: 16),
                for (final (mode, label) in options)
                  _LanguageRow(
                    label: label,
                    selected: ThemePreference.mode.value == mode,
                    onTap: () {
                      unawaited(ThemePreference.select(mode));
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            if (selected)
              HugeIcon(
                icon: AppIcons.checkCircle,
                color: context.palette.success,
              ),
          ],
        ),
      ),
    );
  }
}
