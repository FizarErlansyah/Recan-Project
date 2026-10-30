import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/education_catalog.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class EducationService {
  const new _();

  static const int featuredCount = 2;
  static const int relatedCount = 3;
  static const int helpfulBonusPoints = 5;

  static List<EducationArticle> get featured =>
      EducationCatalog.articles.take(featuredCount).toList();

  static Future<List<EducationArticle>> fetch() =>
      SynchronousFuture(List.unmodifiable(EducationCatalog.articles));

  static List<EducationArticle> related(EducationArticle article) {
    final others =
        EducationCatalog.articles
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
      MockStore.bookmarkedArticleIds.contains(articleId);

  static bool toggleBookmark(int articleId) {
    final saved = MockStore.bookmarkedArticleIds;
    if (!saved.remove(articleId)) saved.add(articleId);
    return saved.contains(articleId);
  }

  static bool isHelpfulClaimed(int articleId) =>
      MockStore.helpfulClaimedArticleIds.contains(articleId);

  static Future<void> claimHelpfulBonus(int articleId) {
    if (!MockStore.claimHelpfulBonus(articleId, helpfulBonusPoints)) {
      return Future.error(
        ApiException(
          tr(
            'Bonus artikel ini sudah kamu klaim.',
            'You already claimed the bonus for this article.',
          ),
        ),
      );
    }
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }
}
