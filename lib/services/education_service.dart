import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';

class EducationService {
  const new _();

  static const int featuredCount = 2;
  static const int relatedCount = 3;
  static const int helpfulBonusPoints = 5;

  static List<EducationArticle> get featured =>
      Backend.current.cachedArticles.take(featuredCount).toList();

  static Future<List<EducationArticle>> fetch() => Backend.current.articles();

  static List<EducationArticle> related(EducationArticle article) {
    final others =
        Backend.current.cachedArticles
            .where((item) => item.id != article.id)
            .toList()
          ..sort((a, b) {
            final aSame = a.category == article.category ? 0 : 1;
            final bSame = b.category == article.category ? 0 : 1;
            return aSame.compareTo(bSame);
          });
    return others.take(relatedCount).toList();
  }

  static bool isBookmarked(int articleId) =>
      Backend.current.isBookmarked(articleId);

  static bool toggleBookmark(int articleId) =>
      Backend.current.toggleBookmark(articleId);

  static bool isHelpfulClaimed(int articleId) =>
      Backend.current.isBonusClaimed(articleId);

  static Future<void> claimHelpfulBonus(int articleId) async {
    await Backend.current.claimArticleBonus(articleId);
    DataRefresh.notifyChanged();
  }
}
