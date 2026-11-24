import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class TransactionService {
  const new _();

  /// [collective] marks the community-event drop that may exceed one bin.
  static Future<void> submitDrop(
    int cansCount, {
    int? stationId,
    bool collective = false,
  }) async {
    if (cansCount <= 0) {
      throw ApiException(
        tr('Jumlah kaleng tidak valid.', 'Invalid number of cans.'),
      );
    }
    await Backend.current.submitDrop(
      cans: cansCount,
      stationId: stationId,
      collective: collective,
    );
    DataRefresh.notifyChanged();
  }

  static Future<String> redeem({
    required int productId,
    required int quantity,
    required String shippingAddress,
    String? notes,
  }) => _settle(
    Backend.current.redeemProduct(
      productId: productId,
      quantity: quantity,
      shippingAddress: shippingAddress,
      notes: notes,
    ),
  );

  static Future<String> redeemEWallet(EWalletOption option) =>
      _settle(Backend.current.redeemEWallet(option));

  static Future<String> redeemVoucher(Voucher voucher) =>
      _settle(Backend.current.redeemVoucher(voucher));

  static Future<String> _settle(Future<String> redeem) async {
    final reference = await redeem;
    DataRefresh.notifyChanged();
    return reference;
  }
}
