import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class EducationCard extends StatelessWidget {
  const new({required this.article, required this.onTap, super.key});

  final EducationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ReCanCard(
      onTap: onTap,
      child: Row(
        children: [
          _CategoryTile(category: article.category),
          const SizedBox(width: 16),
          Expanded(child: _Summary(article: article)),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const new({required this.category});

  final EducationCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: category.gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: HugeIcon(icon: category.icon, color: AppColors.white, size: 32),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.article});

  final EducationArticle article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.category.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: context.palette.accent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          article.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        _ReadingTime(minutes: article.readMinutes),
      ],
    );
  }
}

class _ReadingTime extends StatelessWidget {
  const new({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: AppIcons.clock,
          size: 14,
          color: context.palette.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$minutes ${tr('menit baca', 'min read')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
