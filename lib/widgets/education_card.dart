import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class EducationCard extends StatelessWidget {
  const new({required this.article, required this.onTap, super.key});

  final EducationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = article.category;

    return ReCanCard(
      radius: 16,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: category.gradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: AppColors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(color: AppColors.sage),
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
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${article.readMinutes} ${tr('menit baca', 'min read')}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
