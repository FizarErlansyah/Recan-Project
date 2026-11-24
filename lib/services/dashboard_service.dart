import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class DashboardService {
  const new _();

  static Future<DashboardData> fetch() => Backend.current.dashboard();
}
