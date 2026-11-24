import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class ActivityService {
  const new _();

  static Future<List<ActivityTransaction>> fetch() =>
      Backend.current.activities();
}
