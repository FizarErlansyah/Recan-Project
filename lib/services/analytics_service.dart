import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class AnalyticsService {
  const new _();

  static Future<CarbonImpact> fetchCarbonImpact(CarbonRange range) =>
      Backend.current.carbonImpact(range);
}
