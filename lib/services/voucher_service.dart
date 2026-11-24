import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class VoucherService {
  const new _();

  static Future<List<Voucher>> fetch() => Backend.current.vouchers();

  static Future<List<OwnedVoucher>> owned() => Backend.current.ownedVouchers();
}
