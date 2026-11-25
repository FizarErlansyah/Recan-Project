import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
    return BouncyTap(
      haptic: true,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: entry.onTap,
          borderRadius: BorderRadius.circular(16),
          child: _CategoryFace(entry: entry),
        ),
      ),
    );
  }
}

class _CategoryFace extends StatelessWidget {
  const new({required this.entry});

  final CategoryMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconTile(icon: entry.icon),
          const SizedBox(height: 8),
          Text(
            entry.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const new({required this.icon});

  final AppIconBuilder icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: icon(color: context.palette.accent, size: 22),
    );
  }
}
