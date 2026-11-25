import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';

class VoucherService {
  const new _();

  static Future<List<Voucher>> fetch() => Backend.current.vouchers();

  static Future<List<OwnedVoucher>> owned() => Backend.current.ownedVouchers();

  /// Marks the voucher as used; the server refuses a second or late use.
  static Future<void> use(String reference) async {
    await Backend.current.useVoucher(reference);
    DataRefresh.notifyChanged();
  }
}
