import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

/// Stand-in for a remote backend: it records what the services ask for and
/// answers only the few calls a test needs. Anything else throws, so a test
/// never reaches a real server by accident.
class RecordingBackend extends Fake implements AppBackend {
  new({
    this.remote = false,
    this.editableEmail = true,
    this.signUpSignsIn = true,
    this.pending,
    this.dropFailure,
    this.station,
    this.checkIn,
    this.signInFailure,
  });

  final bool remote;
  final bool editableEmail;
  final bool signUpSignsIn;

  /// When set, write calls stay in flight until it completes.
  final Future<void>? pending;
  final Exception? dropFailure;
  final ScannedStation? station;
  final DailyCheckIn? checkIn;
  final Exception? signInFailure;
  final List<String> calls = [];

  @override
  bool get isRemote => remote;

  @override
  bool get canEditEmail => editableEmail;

  @override
  Future<bool> restoreSession() async => false;

  @override
  Future<bool> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    calls.add('signUp:$username:$fullName:$email:$phone');
    return signUpSignsIn;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    calls.add('signIn:$email');
    await pending;
    final failure = signInFailure;
    if (failure != null) throw failure;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    await pending;
  }

  @override
  Future<ScannedStation?> stationByQr(String code) async {
    calls.add('station:$code');
    return station;
  }

  @override
  Future<void> submitDrop({
    required int cans,
    required int stationId,
    required String qrCode,
  }) async {
    calls.add('drop:$cans:$stationId:$qrCode');
    await pending;
    final failure = dropFailure;
    if (failure != null) throw failure;
  }

  @override
  Future<PurchaseReceipt> redeemProduct({
    required int productId,
    required int quantity,
    required String shippingAddress,
    required int pointsUsed,
    PaymentChannel? channel,
    String? notes,
  }) async {
    calls.add(
      'redeem:$productId:$quantity:$shippingAddress:$pointsUsed:${channel?.code}',
    );
    await pending;
    return PurchaseReceipt(
      reference: 'REC-TEST1',
      pointsUsed: pointsUsed,
      cashPaid: 0,
    );
  }

  @override
  Future<String> redeemVoucher(Object? voucher) async {
    calls.add('voucher');
    await pending;
    return 'REC-TEST2';
  }

  @override
  GamificationData? get cachedGamification => null;

  @override
  Future<GamificationData> gamification() async =>
      GamificationData(dailyQuests: const [], checkIn: checkIn!);

  @override
  Future<void> claimCheckIn() async {
    calls.add('claimCheckIn');
    await pending;
  }

  @override
  Future<void> claimQuest(int questId) async {
    calls.add('claimQuest:$questId');
    await pending;
  }
}
