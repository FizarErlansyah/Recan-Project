import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'support/screen.dart';

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');

/// Plays Android: only a request can report "permanently denied", while a
/// status check answers plain "denied" for the same state.
class _Android {
  PermissionStatus requestAnswer = PermissionStatus.denied;
  PermissionStatus statusAnswer = PermissionStatus.denied;
  Completer<void>? holdRequest;
  int requests = 0;
  int checks = 0;
  int settingsOpened = 0;

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'requestPermissions':
        requests++;
        await holdRequest?.future;
        return {Permission.camera.value: requestAnswer.index};
      case 'checkPermissionStatus':
        checks++;
        return statusAnswer.index;
      case 'openAppSettings':
        settingsOpened++;
        return true;
    }
    return null;
  }
}

void main() {
  late _Android android;

  setUp(() {
    android = _Android();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, android.handle);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  final allow = find.widgetWithText(FilledButton, 'Izinkan Kamera');
  final settings = find.widgetWithText(FilledButton, 'Buka Pengaturan');

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(testApp(const ScanQrPage()));
    await tester.pumpAndSettle();
  }

  // What the system permission screen does to the app: cover it, then leave.
  Future<void> coverAndReturn(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  testWidgets('a first denial offers to allow and never asks by itself', (
    tester,
  ) async {
    await open(tester);

    for (var i = 0; i < 5; i++) {
      await coverAndReturn(tester);
    }

    expect(android.requests, 1);
    expect(android.checks, 5);
    expect(allow, findsOneWidget);
    expect(settings, findsNothing);
  });

  testWidgets('a permanent denial keeps pointing at the settings', (
    tester,
  ) async {
    await open(tester);
    android.requestAnswer = PermissionStatus.permanentlyDenied;

    await tester.tap(allow);
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await coverAndReturn(tester);
    }

    expect(android.requests, 2);
    expect(settings, findsOneWidget);
    expect(allow, findsNothing);
    expect(find.textContaining('Pengaturan'), findsWidgets);
  });

  testWidgets('the settings button opens settings without asking again', (
    tester,
  ) async {
    android.requestAnswer = PermissionStatus.permanentlyDenied;
    await open(tester);

    await tester.tap(settings);
    await coverAndReturn(tester);

    expect(android.settingsOpened, 1);
    expect(android.requests, 1);
  });

  testWidgets('a return while the system dialog is open changes nothing', (
    tester,
  ) async {
    android.holdRequest = Completer<void>();
    await tester.pumpWidget(testApp(const ScanQrPage()));
    await tester.pump();

    await coverAndReturn(tester);
    expect(android.requests, 1);
    expect(android.checks, 0);

    android.requestAnswer = PermissionStatus.permanentlyDenied;
    android.holdRequest!.complete();
    await tester.pumpAndSettle();
    expect(settings, findsOneWidget);
  });

  testWidgets('a double tap asks only once', (tester) async {
    await open(tester);
    android.holdRequest = Completer<void>();

    await tester.tap(allow);
    await tester.tap(allow);
    await tester.pump();

    expect(android.requests, 2);
    android.holdRequest!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('allowing it in settings shows the scanner on return', (
    tester,
  ) async {
    android.requestAnswer = PermissionStatus.permanentlyDenied;
    await open(tester);
    android.statusAnswer = PermissionStatus.granted;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(find.byType(MobileScanner), findsOneWidget);
    expect(settings, findsNothing);
    expect(android.requests, 1);
  });
}
