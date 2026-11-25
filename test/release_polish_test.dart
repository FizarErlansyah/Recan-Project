import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/splash_page.dart';
import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/brushed_metal.dart';
import 'package:mobile_apps_recan/widgets/home_hero_header.dart';
import 'package:mobile_apps_recan/widgets/motion/balance_hero.dart';
import 'package:mobile_apps_recan/widgets/tab_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palette_test.dart' show contrast;
import 'support/screen.dart';

/// The mock, counting how often each screen asks for its data.
final class _CountingBackend extends MockBackend {
  final Map<String, int> calls = {};

  void _count(String name) => calls[name] = (calls[name] ?? 0) + 1;

  @override
  Future<DashboardData> dashboard() {
    _count('dashboard');
    return super.dashboard();
  }

  @override
  Future<ProfileOverview> overview() {
    _count('overview');
    return super.overview();
  }

  @override
  Future<List<UpcycleProduct>> products() {
    _count('products');
    return super.products();
  }
}

bool _isHairline(Symbol method, List<dynamic> arguments) =>
    method == #drawRect && (arguments.first as Rect).width == 1;

void main() {
  tearDown(() {
    Backend.current = MockBackend();
    MockStore.resetDemoState();
  });

  group('tab transition', () {
    Widget stack(int active) => testApp(
      Scaffold(
        body: Stack(
          children: [
            for (var i = 0; i < 3; i++)
              TabSlot(
                active: i == active,
                side: (i - active).sign,
                child: Center(child: Text('tab $i')),
              ),
          ],
        ),
      ),
    );
    double x(WidgetTester tester, int i) =>
        tester.getCenter(find.text('tab $i')).dx;

    testWidgets('a tab to the right slides in from the right', (tester) async {
      await tester.pumpWidget(stack(0));
      final centre = x(tester, 0);

      await tester.pumpWidget(stack(2));
      await tester.pump(const Duration(milliseconds: 60));

      expect(x(tester, 2), greaterThan(centre + 4));
      expect(x(tester, 0), lessThan(centre));
      await tester.pumpAndSettle();
      expect(x(tester, 2), closeTo(centre, 0.5));
      expect(find.text('tab 0'), findsNothing);
    });

    testWidgets('a tab to the left slides in from the left', (tester) async {
      await tester.pumpWidget(stack(2));
      final centre = x(tester, 2);

      await tester.pumpWidget(stack(0));
      await tester.pump(const Duration(milliseconds: 60));

      expect(x(tester, 0), lessThan(centre - 4));
      expect(x(tester, 2), greaterThan(centre));
      await tester.pumpAndSettle();
    });

    testWidgets('finishes within the flagship window', (tester) async {
      expect(TabSlot.duration.inMilliseconds, inInclusiveRange(260, 320));
      expect(TabSlot.restScale, 0.985);
    });
  });

  testWidgets('switching tabs never reloads a tab', (tester) async {
    final backend = _CountingBackend();
    Backend.current = backend;
    useTallPhone(tester);
    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);
    final first = Map<String, int>.of(backend.calls);

    for (final tab in ['Katalog', 'Aktivitas', 'Profil', 'Beranda']) {
      await tester.tap(find.text(tab).last);
      await pumpFrames(tester, 5);
    }
    for (final tab in ['Katalog', 'Beranda']) {
      await tester.tap(find.text(tab).last);
      await pumpFrames(tester, 5);
    }

    expect(first['products'], 1, reason: 'tabs are warmed up front');
    expect(backend.calls, first);
  });

  testWidgets('the other tabs load only after the entrance transition', (
    tester,
  ) async {
    final backend = _CountingBackend();
    Backend.current = backend;
    useTallPhone(tester);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigator, home: const Scaffold()),
    );

    // Building three more pages mid-flight would stall the splash morph.
    navigator.currentState!.pushReplacement(
      PageRouteBuilder<void>(pageBuilder: (_, _, _) => const HomePage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(backend.calls['products'], isNull);

    await pumpFrames(tester);
    expect(backend.calls['products'], 1);
  });

  testWidgets('catalog sub-tabs keep their data', (tester) async {
    final backend = _CountingBackend();
    Backend.current = backend;
    useTallPhone(tester);
    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);
    await tester.tap(find.text('Katalog').last);
    await pumpFrames(tester, 5);
    final before = backend.calls['products'];

    for (final tab in ['Voucher', 'Kriya ReCan', 'Voucher', 'Kriya ReCan']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }

    expect(backend.calls['products'], before);
  });

  group('splash', () {
    for (final signedIn in [true, false]) {
      testWidgets('shows on every cold start (signed in: $signedIn)', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({
          'onboarding_completed': true,
          if (signedIn) ApiConfig.tokenKey: 'mock-session',
        });
        await tester.pumpWidget(const ReCanApp());
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(SplashPage), findsOneWidget);
        expect(find.byType(BalanceHero), findsOneWidget);
        await pumpFrames(tester, 25);
      });
    }

    testWidgets('morphs into the balance card without overflowing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        ApiConfig.tokenKey: 'mock-session',
      });
      await tester.pumpWidget(const ReCanApp());
      await tester.pump(const Duration(milliseconds: 1050));
      await tester.pump();
      var flew = false;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        if (find.byType(BalanceFlight).evaluate().isNotEmpty) flew = true;
        expect(tester.takeException(), isNull);
      }
      await pumpFrames(tester);

      expect(flew, isTrue);
      expect(
        find.descendant(
          of: find.byType(HomeHeroHeader),
          matching: find.byType(BalanceHero),
        ),
        findsOneWidget,
      );
    });
  });

  group('metallic balance card', () {
    for (final brightness in Brightness.values) {
      final palette = brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;

      test('${brightness.name} metal keeps text and buttons sharp', () {
        for (final tone in BrushedMetal.tones(brightness)) {
          final lit = Color.alphaBlend(BrushedMetal.glint(brightness), tone);
          for (final ground in [tone, lit]) {
            for (final text in [
              palette.textPrimary,
              palette.textSecondary,
              palette.accent,
            ]) {
              expect(contrast(text, ground), greaterThanOrEqualTo(4.5));
            }
            expect(contrast(palette.primary, ground), greaterThanOrEqualTo(3));
          }
        }
      });
    }

    Widget header({bool still = false}) => testApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: still),
          child: Scaffold(
            body: ListView(
              children: [
                HomeHeroHeader(
                  user: const UserProfile(
                    id: 'u',
                    name: 'Budi',
                    email: 'b@recan.id',
                    pointsBalance: 100,
                  ),
                  cansDeposited: 4,
                  onAskAi: () {},
                  onScan: () {},
                  onOpenProfile: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name} metal reflects like the tier card', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            Center(
              child: SizedBox(
                width: 300,
                height: 180,
                child: MetalSheen(
                  brightness: brightness,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
        final surface = find
            .descendant(
              of: find.byType(MetalSheen),
              matching: find.byType(CustomPaint),
            )
            .first;

        // Flat horizontal strokes read as stripes, not as polished metal.
        expect(surface, isNot(paints..line()));
        expect(
          surface,
          paints
            ..rotate()
            ..something(_isHairline)
            ..something(_isHairline),
        );
      });
    }

    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name} metal stays readable where text sits', (
        tester,
      ) async {
        const size = Size(300, 180);
        final shot = GlobalKey();
        await tester.pumpWidget(
          testApp(
            Center(
              child: RepaintBoundary(
                key: shot,
                child: SizedBox.fromSize(
                  size: size,
                  child: MetalSheen(
                    brightness: brightness,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        );
        final pixels = await tester.runAsync(() async {
          final boundary =
              shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          return await image.toByteData();
        });
        final text = brightness == Brightness.dark
            ? AppPalette.dark.textSecondary
            : AppPalette.light.textSecondary;

        // Below the midline the hairlines are gone and the labels begin.
        var worst = double.infinity;
        for (var y = 100; y < size.height; y++) {
          for (var x = 0; x < size.width; x++) {
            final at = (y * size.width.toInt() + x) * 4;
            final ground = Color.fromARGB(
              255,
              pixels!.getUint8(at),
              pixels.getUint8(at + 1),
              pixels.getUint8(at + 2),
            );
            worst = math.min(worst, contrast(text, ground));
          }
        }

        expect(worst, greaterThanOrEqualTo(4.5));
      });
    }

    testWidgets('sweeps its sheen once and then rests', (tester) async {
      await tester.pumpWidget(header());
      double sheen() =>
          tester.widget<MetalSheen>(find.byType(MetalSheen).first).sweep;
      await tester.pump(const Duration(milliseconds: 100));
      final early = sheen();
      await tester.pump(const Duration(milliseconds: 900));
      expect(sheen(), greaterThan(early));

      await tester.pumpAndSettle();
      expect(sheen(), 1);
    });

    testWidgets('has no sweep under reduced motion', (tester) async {
      await tester.pumpWidget(header(still: true));

      expect(tester.widget<MetalSheen>(find.byType(MetalSheen).first).sweep, 1);
    });

    testWidgets('sits close under the greeting', (tester) async {
      await tester.pumpWidget(header());
      await tester.pumpAndSettle();

      final greetingBottom = tester.getBottomLeft(find.text('Hai Budi')).dy;
      final cardTop = tester.getTopLeft(find.byType(BrushedMetal)).dy;

      expect(cardTop - greetingBottom, inInclusiveRange(8, 26));
    });
  });
}
