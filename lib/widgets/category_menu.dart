import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

class CategoryMenuEntry {
  const new({required this.icon, required this.label, required this.onTap});

  final AppIconBuilder icon;
  final String label;
  final VoidCallback onTap;
}

class CategoryMenu extends StatelessWidget {
  const new({required this.entries, super.key});

  final List<CategoryMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          for (final entry in entries) ...[
            Expanded(child: _CategoryButton(entry: entry)),
          ],
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const new({required this.entry});

  final CategoryMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Pressable(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: entry.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                entry.icon(color: context.palette.accent, size: 22),
                const SizedBox(height: 6),
                Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
