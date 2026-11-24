import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/services/voucher_service.dart';

void main() {
  late int startingPoints;

  setUp(() {
    startingPoints = MockStore.points;
    MockStore.ownedVouchers.clear();
  });

  tearDown(() {
    MockStore.points = startingPoints;
    MockStore.ownedVouchers.clear();
    MockStore.activities.clear();
  });

  test(
    'redeeming a voucher makes it an active voucher on the profile',
    () async {
      final voucher = MockStore.vouchers.first;
      MockStore.points = voucher.pointsCost;
      expect(MockStore.profile.activeVouchers, 0);

      final reference = await TransactionService.redeemVoucher(voucher);

      expect(MockStore.profile.activeVouchers, 1);
      expect(MockStore.profile.points, 0);
      final owned = await VoucherService.owned();
      expect(owned.single.voucher.id, voucher.id);
      expect(owned.single.reference, reference);
    },
  );

  test(
    'a voucher that cannot be afforded is not added to the wallet',
    () async {
      final voucher = MockStore.vouchers.first;
      MockStore.points = voucher.pointsCost - 1;

      await expectLater(
        TransactionService.redeemVoucher(voucher),
        throwsA(anything),
      );

      expect(MockStore.profile.activeVouchers, 0);
    },
  );
}
