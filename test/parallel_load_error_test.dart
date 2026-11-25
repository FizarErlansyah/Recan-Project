import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/home/presentation/home_insights_section.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_catalog_view.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/screen.dart';

const _expired = ApiException('Sesi berakhir.', unauthorized: true);

/// Answers one half of a screen's parallel load and refuses the other.
class _HalfBackend extends Fake implements AppBackend {
  @override
  Future<ProfileData> profile() async => MockStore.profile;

  @override
  Future<List<Voucher>> vouchers() async => throw _expired;

  @override
  Future<List<ActivityTransaction>> activities() async => throw _expired;

  @override
  Future<Never> gamification() async => throw _expired;
}

void main() {
  setUp(() => Backend.current = _HalfBackend());
  tearDown(() => Backend.current = MockBackend());

  Future<void> expectsSignInAgain(
    WidgetTester tester,
    Widget Function(VoidCallback onLogout) screen,
  ) async {
    var logouts = 0;
    useTallPhone(tester);
    await tester.pumpWidget(testApp(Scaffold(body: screen(() => logouts++))));
    await tester.pumpAndSettle();

    expect(find.text('Sesi berakhir.'), findsOneWidget);
    await tester.tap(find.text('Masuk Kembali'));
    expect(logouts, 1);
  }

  testWidgets('the voucher tab keeps the reason a load failed', (tester) async {
    await expectsSignInAgain(
      tester,
      (onLogout) => VoucherCatalogView(onLogout: onLogout),
    );
  });

  testWidgets('the home insights keep the reason a load failed', (
    tester,
  ) async {
    await expectsSignInAgain(
      tester,
      (onLogout) => HomeInsightsSection(
        refreshOn: ValueNotifier(0),
        onUnauthorized: onLogout,
        onScan: () {},
        onOpenQuests: () {},
        onSeeAllActivity: () {},
      ),
    );
  });
}
