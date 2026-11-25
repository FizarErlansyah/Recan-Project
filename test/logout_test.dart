import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:mobile_apps_recan/widgets/settings_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/screen.dart';

/// Mock data with a sign-out that can be held in flight.
class _SlowSignOut implements AppBackend {
  new(this.gate);

  final Future<void> gate;
  final AppBackend _data = MockBackend();
  int signOuts = 0;

  @override
  Future<void> signOut() async {
    signOuts++;
    await gate;
  }

  @override
  Object? noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #profile) return _data.profile();
    if (invocation.memberName == #overview) return _data.overview();
    if (invocation.memberName == #dashboard) return _data.dashboard();
    if (invocation.memberName == #isRemote) return false;
    if (invocation.memberName == #cachedArticles) return _data.cachedArticles;
    if (invocation.memberName == #articles) return _data.articles();
    if (invocation.memberName == #carbonImpact) {
      return _data.carbonImpact(
        invocation.positionalArguments.first as CarbonRange,
      );
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      ApiConfig.tokenKey: 'mock-session',
    }),
  );
  tearDown(() => Backend.current = MockBackend());

  Future<void> openProfile(
    WidgetTester tester, {
    double bottomInset = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(411, 891);
    tester.view.padding = FakeViewPadding(bottom: bottomInset);
    tester.view.viewPadding = FakeViewPadding(bottom: bottomInset);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);
    await tester.tap(find.text('Profil'));
    await pumpFrames(tester);
    await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
    await pumpFrames(tester);
  }

  final logoutTile = find.widgetWithText(SettingsTile, 'Keluar');
  final confirmButton = find.byKey(const ValueKey('logout-confirm'));

  testWidgets('the logout row clears the nav bar and the gesture bar', (
    tester,
  ) async {
    await openProfile(tester, bottomInset: 48);

    final navTop =
        tester.getRect(find.byType(MainNavBar)).top + MainNavBar.overhang;
    expect(tester.getRect(logoutTile).bottom, lessThanOrEqualTo(navTop));

    await tester.tap(logoutTile);
    await pumpFrames(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('cancelling keeps the session', (tester) async {
    await openProfile(tester);
    await tester.tap(logoutTile);
    await pumpFrames(tester);

    await tester.tap(find.text('Batal'));
    await pumpFrames(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('confirming clears the session and resets to login', (
    tester,
  ) async {
    HomeNavigation.requestedTab.value = null;
    await openProfile(tester);
    await tester.tap(logoutTile);
    await pumpFrames(tester);

    await tester.tap(confirmButton);
    await pumpFrames(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage, skipOffstage: false), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    expect(await AuthService.restoreSession(), isFalse);
  });

  testWidgets('a double tap signs out once and locks the dialog', (
    tester,
  ) async {
    final gate = Completer<void>();
    final backend = _SlowSignOut(gate.future);
    Backend.current = backend;
    await openProfile(tester);
    await tester.tap(logoutTile);
    await pumpFrames(tester);

    await tester.tap(confirmButton);
    await tester.pump();
    await tester.tap(confirmButton, warnIfMissed: false);
    await tester.pump();

    expect(backend.signOuts, 1);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Batal'))
          .onPressed,
      isNull,
    );
    gate.complete();
    await pumpFrames(tester);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('an expired session on a pushed page also resets the stack', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);
    await tester.tap(find.text('Misi & Hadiah'));
    await pumpFrames(tester);

    tester.widget<QuestPage>(find.byType(QuestPage)).onLogout();
    await pumpFrames(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage, skipOffstage: false), findsNothing);
    expect(find.byType(QuestPage, skipOffstage: false), findsNothing);
  });
}
