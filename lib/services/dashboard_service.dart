import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class DashboardService {
  const new _();

  static Future<DashboardData> fetch() =>
      SynchronousFuture(MockStore.dashboard);
}
