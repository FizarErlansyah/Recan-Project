import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class VoucherService {
  const new _();

  static Future<List<Voucher>> fetch() =>
      SynchronousFuture(List.unmodifiable(MockStore.vouchers));
}
