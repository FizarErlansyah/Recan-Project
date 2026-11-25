import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/pages/profil_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/screen.dart';

final class _HeldBackend extends MockBackend {
  new(this.gate);

  final Completer<void> gate;
  int requests = 0;

  @override
  Future<void> connectGoPay() async {
    requests++;
    await gate.future;
    await super.connectGoPay();
  }
}

void main() {
  late Completer<void> gate;
  late _HeldBackend backend;

  tearDown(() {
    Backend.current = MockBackend();
    MockStore.resetDemoState();
    MockStore.gopayConnected = false;
  });

  const success = 'GoPay berhasil terhubung';
  final connect = find.text('Hubungkan');

  Future<void> open(WidgetTester tester, VoidCallback onLogout) async {
    // Made inside the test, so its completion runs on the test's fake clock.
    gate = Completer<void>();
    backend = _HeldBackend(gate);
    Backend.current = backend;
    MockStore.gopayConnected = false;
    useTallPhone(tester);
    await tester.pumpWidget(
      testApp(Scaffold(body: ProfilPage(onLogout: () async => onLogout()))),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('waits for the server before claiming success', (tester) async {
    await open(tester, () {});

    await tester.tap(connect);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.byKey(const ValueKey('gopay-connect')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(backend.requests, 1);
    expect(find.text(success), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text(success), findsOneWidget);
    expect(find.text('Terhubung'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a refusal shows why and stays unconnected', (tester) async {
    await open(tester, () {});

    await tester.tap(connect);
    await tester.pump();
    gate.completeError(const ApiException('Gagal menghubungkan.'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal menghubungkan.'), findsOneWidget);
    expect(find.text(success), findsNothing);
    expect(connect, findsOneWidget);
  });

  testWidgets('an expired session signs out', (tester) async {
    var logouts = 0;
    await open(tester, () => logouts++);

    await tester.tap(connect);
    await tester.pump();
    gate.completeError(
      const ApiException('Sesi berakhir.', unauthorized: true),
    );
    await tester.pumpAndSettle();

    expect(logouts, 1);
    expect(find.text(success), findsNothing);
  });
}
