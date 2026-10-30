import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class AnalyticsService {
  const new _();

  static Future<CarbonImpact> fetchCarbonImpact(CarbonRange range) =>
      SynchronousFuture(MockStore.carbonImpact(range));
}
