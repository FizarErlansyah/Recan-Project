import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class GamificationService {
  const new _();

  static GamificationData get current => MockStore.gamification;

  static Future<GamificationData> fetch() => SynchronousFuture(current);

  static Future<void> claimCheckIn() {
    if (!MockStore.claimCheckIn()) {
      return Future.error(
        ApiException(
          tr(
            'Hadiah hari ini sudah diklaim.',
            'Your reward for today is already claimed.',
          ),
        ),
      );
    }
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }

  static Future<void> claim(int questId) {
    if (!MockStore.claimQuest(questId)) {
      return Future.error(
        ApiException(
          tr('Misi belum bisa diklaim.', 'Mission cannot be claimed yet.'),
        ),
      );
    }
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }
}
