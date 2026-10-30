import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/pages/article_detail_page.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/education_card.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/filter_chip_row.dart';

class EdukasiPage extends StatefulWidget {
  const new({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(FadePageRoute<void>(page: const EdukasiPage()));
  }

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  int _selectedIndex = 0;

  List<EducationCategory> get _visibleCategories => _selectedIndex == 0
      ? EducationCategory.values
      : [EducationCategory.values[_selectedIndex - 1]];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labels = [
      tr('Semua', 'All'),
      for (final category in EducationCategory.values) category.label,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(tr('Edukasi ReCan', 'ReCan Education'))),
      body: FutureBuilder<List<EducationArticle>>(
        future: EducationService.fetch(),
        builder: (context, snapshot) {
          final articles = snapshot.data ?? const <EducationArticle>[];
          return Column(
            children: [
              const SizedBox(height: 16),
              FilterChipRow(
                labels: labels,
                selectedIndex: _selectedIndex,
                onSelected: (index) => setState(() => _selectedIndex = index),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    for (final category in _visibleCategories) ...[
                      const SizedBox(height: 16),
                      Text(category.label, style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                      for (final article in articles.where(
                        (item) => item.category == category,
                      )) ...[
                        EducationCard(
                          article: article,
                          onTap: () => ArticleDetailPage.open(context, article),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
