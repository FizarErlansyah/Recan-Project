import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class ProductService {
  const new _();

  static Future<List<UpcycleProduct>> fetch() =>
      SynchronousFuture(List.unmodifiable(MockStore.products));
}
