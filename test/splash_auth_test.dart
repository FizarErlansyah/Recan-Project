import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/login_hero.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/recording_backend.dart';
import 'support/screen.dart';

final Finder _loginTab = find.byKey(const ValueKey('auth-tab-login'));
final Finder _registerTab = find.byKey(const ValueKey('auth-tab-register'));
final Finder _submit = find.byKey(const ValueKey('auth-submit'));

void main() {
  tearDown(() => Backend.current = MockBackend());

  group('splash', () {
    Future<void> launch(WidgetTester tester, {required bool signedIn}) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        if (signedIn) ApiConfig.tokenKey: 'mock-session',
      });
      await tester.pumpWidget(const ReCanApp());
    }

    testWidgets('carries the brand mark as a hero', (tester) async {
      await launch(tester, signedIn: false);

      expect(
        find.byWidgetPredicate((w) => w is Hero && w.tag == BrandHero.tag),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });

    test('both brand marks are small enough to decode before the reveal', () {
      const assets = [BrandHero.asset, ReCanLogo.defaultAsset];
      for (final asset in assets) {
        final header = ByteData.sublistView(
          File(asset).readAsBytesSync(),
          0,
          24,
        );
        // Bytes 20 to 23 of a PNG hold its height.
        expect(header.getUint32(20), lessThanOrEqualTo(512), reason: asset);
        expect(File('pubspec.yaml').readAsStringSync(), contains(asset));
      }
    });

    testWidgets('hands over to sign-in within 1.5 seconds', (tester) async {
      await launch(tester, signedIn: false);
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(LoginPage), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoginPage), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('a signed-in user lands on home without hero clashes', (
      tester,
    ) async {
      await launch(tester, signedIn: true);
      await pumpFrames(tester, 25);

      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('sign-in screen', () {
    Future<void> open(WidgetTester tester, {bool still = false}) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: const LoginPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> fillLogin(WidgetTester tester) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'budi@mail.com');
      await tester.enterText(fields.at(1), 'secret1');
    }

    double formHeight(WidgetTester tester) =>
        tester.getSize(find.byKey(const ValueKey('auth-form-area'))).height;

    testWidgets('opens on Masuk and slides to Daftar without a jump', (
      tester,
    ) async {
      await open(tester);
      expect(find.byType(TextFormField), findsNWidgets(2));
      final short = formHeight(tester);

      await tester.tap(_registerTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final midway = formHeight(tester);
      await tester.pumpAndSettle();
      final tall = formHeight(tester);

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(midway, inExclusiveRange(short, tall));

      await tester.tap(_loginTab);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('the header and panel span the whole screen', (tester) async {
      await open(tester);
      // Wider than the header's own text, which is all it would shrink to.
      tester.view.physicalSize = const Size(900, 1600);
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(LoginHero)).width, 900);
      expect(tester.getTopLeft(find.byType(LoginHero)), Offset.zero);
    });

    testWidgets('switching still works under reduced motion', (tester) async {
      await open(tester, still: true);

      await tester.tap(_registerTab);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('a rejected form shakes and explains itself inline', (
      tester,
    ) async {
      await open(tester);
      final rest = tester.getTopLeft(find.byType(TextFormField).first).dx;

      await tester.tap(_submit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(
        tester.getTopLeft(find.byType(TextFormField).first).dx,
        isNot(rest),
      );

      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(TextFormField).first).dx, rest);
    });

    testWidgets('the button morphs into a spinner and back on failure', (
      tester,
    ) async {
      final inFlight = Completer<void>();
      final backend = RecordingBackend(
        pending: inFlight.future,
        signInFailure: const AuthException('Email atau kata sandi salah.'),
      );
      Backend.current = backend;
      await open(tester);
      await fillLogin(tester);
      final wide = tester.getSize(_submit).width;

      await tester.tap(_submit);
      await tester.tap(_submit, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.getSize(_submit).width, 52);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(backend.calls, ['signIn:budi@mail.com']);
      await tester.tap(_registerTab, warnIfMissed: false);
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(2));

      inFlight.complete();
      await tester.pumpAndSettle();
      expect(tester.getSize(_submit).width, wide);
      expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('changing mode clears the error', (tester) async {
      Backend.current = RecordingBackend(
        signInFailure: const AuthException('Email atau kata sandi salah.'),
      );
      await open(tester);
      await fillLogin(tester);
      await tester.tap(_submit);
      await tester.pumpAndSettle();

      await tester.tap(_registerTab);
      await tester.pumpAndSettle();

      expect(find.text('Email atau kata sandi salah.'), findsNothing);
    });
  });
}
