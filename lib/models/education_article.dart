import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum EducationCategory {
  about(AppIcons.recycle),
  importance(AppIcons.autorenew),
  impact(AppIcons.globe);

  new(this.icon);

  static EducationCategory parse(String? raw) => EducationCategory.values
      .firstWhere((value) => value.name == raw, orElse: () => about);

  final IconGlyph icon;

  String get label => switch (this) {
    about => tr('Tentang ReCan', 'About ReCan'),
    importance => tr('Pentingnya Daur Ulang', 'Why Recycling Matters'),
    impact => tr('Dampak Lingkungan', 'Environmental Impact'),
  };

  List<Color> get gradient => switch (this) {
    about => const [AppColors.primary, AppColors.primaryDark],
    importance => const [AppColors.primaryDark, AppColors.primaryLight],
    impact => const [AppColors.slate, AppColors.slateDeep],
  };
}

class ArticleStat {
  const new({
    required this.value,
    required this.labelId,
    required this.labelEn,
  });

  factory fromJson(Map<String, dynamic> json) => ArticleStat(
    value: json['value'] as String,
    labelId: json['label'] as String,
    labelEn: json['label_en'] as String,
  );

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

  /// Reads an `education_articles` row.
  factory fromJson(Map<String, dynamic> json) => EducationArticle(
    id: json['id'] as int,
    category: EducationCategory.parse(json['category'] as String?),
    titleId: json['title'] as String,
    titleEn: json['title_en'] as String,
    summaryId: json['summary'] as String,
    summaryEn: json['summary_en'] as String,
    paragraphsId: List<String>.from(json['paragraphs'] as List<dynamic>),
    paragraphsEn: List<String>.from(json['paragraphs_en'] as List<dynamic>),
    insightId: json['insight'] as String,
    insightEn: json['insight_en'] as String,
    stats: [
      for (final stat in json['stats'] as List<dynamic>)
        ArticleStat.fromJson(stat as Map<String, dynamic>),
    ],
    publishedAt: DateTime.parse(json['published_at'] as String).toLocal(),
    readMinutes: (json['read_minutes'] as num).toInt(),
  );

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
