import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class ActivityService {
  const new _();

  static Future<List<ActivityTransaction>> fetch() =>
      SynchronousFuture(List.unmodifiable(MockStore.activities));
}
