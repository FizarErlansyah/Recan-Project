import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum AvatarAction { camera, gallery, remove }

class AvatarSourceSheet extends StatelessWidget {
  const new({required this.hasPhoto, super.key});

  static Future<AvatarAction?> show(
    BuildContext context, {
    required bool hasPhoto,
  }) {
    return showModalBottomSheet<AvatarAction>(
      context: context,
      builder: (_) => AvatarSourceSheet(hasPhoto: hasPhoto),
    );
  }

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Foto Profil', 'Profile Photo'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _ActionRow(
              icon: hugeIcon(AppIcons.camera),
              label: tr('Ambil dari Kamera', 'Take a Photo'),
              onTap: () => Navigator.of(context).pop(AvatarAction.camera),
            ),
            _ActionRow(
              icon: hugeIcon(AppIcons.gallery),
              label: tr('Pilih dari Galeri', 'Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(AvatarAction.gallery),
            ),
            if (hasPhoto)
              _ActionRow(
                icon: hugeIcon(AppIcons.delete),
                label: tr('Hapus Foto', 'Remove Photo'),
                color: context.palette.danger,
                onTap: () => Navigator.of(context).pop(AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final AppIconBuilder icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.palette.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            icon(color: tone, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: tone),
            ),
          ],
        ),
      ),
    );
  }
}
