import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';

/// Stand-in for a remote backend: it records what the services ask for and
/// answers only the few calls a test needs. Anything else throws, so a test
/// never reaches a real server by accident.
class RecordingBackend extends Fake implements AppBackend {
  new({
    this.remote = false,
    this.editableEmail = true,
    this.signUpSignsIn = true,
  });

  final bool remote;
  final bool editableEmail;
  final bool signUpSignsIn;
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
  }

  @override
  Future<void> submitDrop({
    required int cans,
    required int? stationId,
    required bool collective,
  }) async {
    calls.add('drop:$cans:$stationId:$collective');
  }

  @override
  Future<String> redeemProduct({
    required int productId,
    required int quantity,
    required String shippingAddress,
    String? notes,
  }) async {
    calls.add('redeem:$productId:$quantity:$shippingAddress');
    return 'REC-TEST1';
  }

  @override
  Future<void> claimQuest(int questId) async {
    calls.add('claimQuest:$questId');
  }
}
