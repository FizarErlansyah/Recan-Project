import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/faq_item.dart';

class FaqTile extends StatelessWidget {
  const new({required this.item, super.key});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: AppDecorations.card(context),
      // The tile paints its ink on the nearest Material, which must sit above
      // the card colour.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(AppDecorations.radius),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
          child: ExpansionTile(
            minTileHeight: 56,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            iconColor: context.palette.accent,
            collapsedIconColor: context.palette.textSecondary,
            title: Text(item.question, style: textTheme.titleSmall),
            children: [Text(item.answer, style: textTheme.bodyMedium)],
          ),
        ),
      ),
    );
  }
}
