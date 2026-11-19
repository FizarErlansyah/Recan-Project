import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum EducationCategory {
  about(AppIcons.recycle),
  importance(AppIcons.autorenew),
  impact(AppIcons.globe);

  new(this.icon);

  final IconGlyph icon;

  String get label => switch (this) {
    about => tr('Tentang ReCan', 'About ReCan'),
    importance => tr('Pentingnya Daur Ulang', 'Why Recycling Matters'),
    impact => tr('Dampak Lingkungan', 'Environmental Impact'),
  };

  List<Color> get gradient => switch (this) {
    about => const [AppColors.primary, AppColors.primaryDark],
    importance => const [AppColors.primaryDark, AppColors.sage],
    impact => const [AppColors.slate, AppColors.slateDeep],
  };
}

class ArticleStat {
  const new({
    required this.value,
    required this.labelId,
    required this.labelEn,
  });

  final String value;
  final String labelId;
  final String labelEn;

  String get label => tr(labelId, labelEn);
}

class EducationArticle {
  const new({
    required this.id,
    required this.category,
    required this.titleId,
    required this.titleEn,
    required this.summaryId,
    required this.summaryEn,
    required this.paragraphsId,
    required this.paragraphsEn,
    required this.insightId,
    required this.insightEn,
    required this.stats,
    required this.publishedAt,
    required this.readMinutes,
  });

  final int id;
  final EducationCategory category;
  final String titleId;
  final String titleEn;
  final String summaryId;
  final String summaryEn;
  final List<String> paragraphsId;
  final List<String> paragraphsEn;
  final String insightId;
  final String insightEn;
  final List<ArticleStat> stats;
  final DateTime publishedAt;
  final int readMinutes;

  String get title => tr(titleId, titleEn);
  String get summary => tr(summaryId, summaryEn);
  String get insight => tr(insightId, insightEn);
  List<String> get paragraphs => trValue(paragraphsId, paragraphsEn);
}
