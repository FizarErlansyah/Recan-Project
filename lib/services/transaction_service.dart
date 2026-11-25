import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class TransactionService {
  const new _();

  static Future<void> submitDrop(
    int cansCount, {
    required int stationId,
    required String qrCode,
  }) async {
    if (cansCount <= 0) {
      throw ApiException(
        tr('Jumlah kaleng tidak valid.', 'Invalid number of cans.'),
      );
    }
    await Backend.current.submitDrop(
      cans: cansCount,
      stationId: stationId,
      qrCode: qrCode,
    );
    DataRefresh.notifyChanged();
  }

  static Future<PurchaseReceipt> redeem({
    required int productId,
    required int quantity,
    required String shippingAddress,
    required int pointsUsed,
    PaymentChannel? channel,
    String? notes,
  }) => _settle(
    Backend.current.redeemProduct(
      productId: productId,
      quantity: quantity,
      shippingAddress: shippingAddress,
      pointsUsed: pointsUsed,
      channel: channel,
      notes: notes,
    ),
  );

  static Future<String> redeemEWallet(EWalletOption option) =>
      _settle(Backend.current.redeemEWallet(option));

  static Future<String> redeemVoucher(Voucher voucher) =>
      _settle(Backend.current.redeemVoucher(voucher));

  static Future<T> _settle<T>(Future<T> redeem) async {
    final result = await redeem;
    DataRefresh.notifyChanged();
    return result;
  }
}
