import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';

class GamificationService {
  const new _();

  static GamificationData? get current => Backend.current.cachedGamification;

  static Future<GamificationData> fetch() => Backend.current.gamification();

  static Future<void> claimCheckIn() async {
    await Backend.current.claimCheckIn();
    DataRefresh.notifyChanged();
  }

  static Future<void> claim(int questId) async {
    await Backend.current.claimQuest(questId);
    DataRefresh.notifyChanged();
  }
}
