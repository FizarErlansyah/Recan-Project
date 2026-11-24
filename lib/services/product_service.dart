import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class ProductService {
  const new _();

  static Future<List<UpcycleProduct>> fetch() => Backend.current.products();
}
