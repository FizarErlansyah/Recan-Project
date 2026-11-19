import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/article_infographic.dart';
import 'package:mobile_apps_recan/widgets/education_card.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/helpful_bonus_card.dart';
import 'package:mobile_apps_recan/widgets/insight_box.dart';

class ArticleDetailPage extends StatefulWidget {
  const new({required this.article, super.key});

  static const double _expandedHeight = 240;
  static const String _shareBaseUrl = 'https://recan.upj.ac.id/edukasi/';

  static String get _author =>
      tr('Tim Riset ReCan UPJ', 'ReCan UPJ Research Team');

  static void open(
    BuildContext context,
    EducationArticle article, {
    bool replaceCurrent = false,
  }) {
    final route = FadePageRoute<void>(
      page: ArticleDetailPage(article: article),
    );
    final navigator = Navigator.of(context);
    if (replaceCurrent) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  final EducationArticle article;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool _bookmarked = EducationService.isBookmarked(widget.article.id);

  EducationArticle get article => widget.article;

  void _toggleBookmark() {
    final saved = EducationService.toggleBookmark(article.id);
    setState(() => _bookmarked = saved);
    AppSnackBar.show(
      context,
      saved
          ? tr('Artikel disimpan ke bookmark', 'Article saved to bookmarks')
          : tr(
              'Artikel dihapus dari bookmark',
              'Article removed from bookmarks',
            ),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${article.title} - '
            '${ArticleDetailPage._shareBaseUrl}${article.id}',
      ),
    );
    if (!mounted) return;
    AppSnackBar.show(
      context,
      tr('Tautan artikel disalin', 'Article link copied'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = article.category;
    final paragraphs = article.paragraphs;
    final bodyStyle = textTheme.bodyLarge?.copyWith(
      color: context.palette.textPrimary,
      height: 1.6,
    );
    final related = EducationService.related(article);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: ArticleDetailPage._expandedHeight,
            backgroundColor: category.gradient.first,
            foregroundColor: AppColors.white,
            iconTheme: const IconThemeData(color: AppColors.white),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            actions: [
              IconButton(
                tooltip: tr('Simpan artikel', 'Save article'),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: HugeIcon(
                  icon: AppIcons.bookmark,
                  color: AppColors.white,
                  size: 22,
                  strokeWidth: _bookmarked ? 2.6 : 1.5,
                ),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                tooltip: tr('Bagikan', 'Share'),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const HugeIcon(
                  icon: AppIcons.share,
                  color: AppColors.white,
                  size: 22,
                ),
                onPressed: _share,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ArticleHero(article: article),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  article.title,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _MetaRow(article: article),
                const SizedBox(height: 24),
                Divider(color: context.palette.border, height: 1),
                const SizedBox(height: 24),
                Text(paragraphs[0], style: bodyStyle),
                const SizedBox(height: 24),
                InsightBox(
                  text: article.insight,
                  accent: category.gradient.first,
                ),
                const SizedBox(height: 24),
                Text(paragraphs[1], style: bodyStyle),
                const SizedBox(height: 24),
                ArticleInfographic(
                  stats: article.stats,
                  colors: category.gradient,
                ),
                const SizedBox(height: 24),
                Text(paragraphs[2], style: bodyStyle),
                for (final paragraph in paragraphs.skip(3)) ...[
                  const SizedBox(height: 24),
                  Text(paragraph, style: bodyStyle),
                ],
                const SizedBox(height: 32),
                HelpfulBonusCard(
                  key: ValueKey(article.id),
                  articleId: article.id,
                ),
                const SizedBox(height: 32),
                Text(
                  tr('Artikel Terkait Lainnya', 'More Related Articles'),
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final other in related) ...[
                  EducationCard(
                    article: other,
                    onTap: () => ArticleDetailPage.open(
                      context,
                      other,
                      replaceCurrent: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  const new({required this.article});

  final EducationArticle article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = article.category;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: category.gradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: 40,
            child: HugeIcon(
              icon: category.icon,
              size: 200,
              color: AppColors.white.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: category.icon,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const new({required this.article});

  final EducationArticle article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const HugeIcon(
            icon: AppIcons.science,
            color: AppColors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ArticleDetailPage._author, style: textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                '${IndonesianDate.date(article.publishedAt)} · '
                '${article.readMinutes} ${tr('menit baca', 'min read')}',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
