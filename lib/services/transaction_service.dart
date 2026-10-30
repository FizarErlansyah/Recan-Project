import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class TransactionService {
  const new _();

  static Future<void> submitDrop(int cansCount) {
    if (cansCount <= 0) {
      return Future.error(
        ApiException(
          tr('Jumlah kaleng tidak valid.', 'Invalid number of cans.'),
        ),
      );
    }
    MockStore.recordDeposit(cansCount);
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }

  static Future<String> redeem({
    required int productId,
    required int quantity,
    required String shippingAddress,
    String? notes,
  }) =>
      _settle(MockStore.recordRedeem(productId: productId, quantity: quantity));

  static Future<String> redeemEWallet(EWalletOption option) =>
      _settle(MockStore.recordEWalletRedeem(option));

  static Future<String> redeemVoucher(Voucher voucher) =>
      _settle(MockStore.recordVoucherRedeem(voucher));

  static Future<String> _settle(
    ({String? failure, String? transactionId}) result,
  ) {
    final failure = result.failure;
    if (failure != null) return Future.error(ApiException(failure));
    DataRefresh.notifyChanged();
    return SynchronousFuture(result.transactionId!);
  }
}
