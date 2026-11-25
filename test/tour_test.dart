import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/tour/data/tour_store.dart';
import 'package:mobile_apps_recan/features/tour/domain/tour_step.dart';
import 'package:mobile_apps_recan/features/tour/presentation/coach_mark_overlay.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/brushed_metal.dart';
import 'package:mobile_apps_recan/widgets/category_menu.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/screen.dart';
import 'support/tour_stores.dart';

final Finder _overlay = find.byType(CoachMarkOverlay);

Rect _hole(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.byKey(const ValueKey('tour-spotlight')),
  );
  return (paint.painter! as TourSpotlightPainter).hole!;
}

void main() {
  late MemoryTourStore store;

  setUp(() {
    store = MemoryTourStore();
    TourStore.current = store;
  });
  tearDown(() {
    TourStore.current = const FinishedTourStore();
    MockStore.resetDemoState();
    MockStore.isEnglish.value = false;
    HomeNavigation.requestedTab.value = null;
  });

  Future<void> openHome(
    WidgetTester tester, {
    Size size = const Size(411, 891),
    ThemeData? theme,
    double scale = 1,
    bool still = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: still,
          ),
          child: child!,
        ),
        home: const HomePage(),
      ),
    );
    await pumpFrames(tester);
  }

  Future<void> press(WidgetTester tester, String label) async {
    await tester.tap(find.descendant(of: _overlay, matching: find.text(label)));
    await pumpFrames(tester, 8);
  }

  test('six steps, each written in both languages', () {
    expect(TourStep.home.map((step) => step.target), TourTarget.values);
    for (final step in TourStep.home) {
      for (final text in [
        step.titleId,
        step.titleEn,
        step.bodyId,
        step.bodyEn,
      ]) {
        expect(text.trim(), isNotEmpty);
      }
    }
  });

  test('the saved flag is kept per user', () async {
    SharedPreferences.setMockInitialValues({});
    const saved = PrefsTourStore();

    expect(await saved.isDone('a'), isFalse);
    await saved.markDone('a');

    expect(await saved.isDone('a'), isTrue);
    expect(await saved.isDone('b'), isFalse);
  });

  testWidgets('greets a new user on Beranda with step one', (tester) async {
    await openHome(tester);

    expect(_overlay, findsOneWidget);
    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('Kembali'), findsNothing);
  });

  testWidgets('stays away once finished', (tester) async {
    await store.markDone(MockStore.profile.id);
    await openHome(tester);

    expect(_overlay, findsNothing);
  });

  testWidgets('walks all six parts, spotlighting each, then saves', (
    tester,
  ) async {
    await openHome(tester);
    final menu = find.byType(CategoryMenu);
    final targets = <Finder>[
      find.byType(BrushedMetal),
      find.descendant(of: menu, matching: find.text('Tukar Poin')),
      find.descendant(of: menu, matching: find.text('Misi')),
      find.descendant(of: menu, matching: find.text('Drop Station')),
      find.descendant(of: menu, matching: find.text('Edukasi')),
      find.descendant(
        of: find.byType(MainNavBar),
        matching: find.text('Aktivitas'),
      ),
    ];

    for (var i = 0; i < targets.length; i++) {
      expect(find.text('${i + 1}/6'), findsOneWidget);
      final hole = _hole(tester);
      expect(
        hole.contains(tester.getCenter(targets[i].first)),
        isTrue,
        reason: 'step ${i + 1} must light its target',
      );
      if (i < targets.length - 1) await press(tester, 'Lanjut');
    }
    expect(
      _hole(tester).contains(
        tester.getCenter(
          find.descendant(
            of: find.byType(MainNavBar),
            matching: find.text('Profil'),
          ),
        ),
      ),
      isTrue,
    );
    expect(find.text('Lewati'), findsNothing);

    await press(tester, 'Mulai');

    expect(_overlay, findsNothing);
    expect(store.done, contains(MockStore.profile.id));
  });

  test('the lit frame stays on screen when its target touches the edges', () {
    const size = Size(400, 800);
    RRect? frame;

    expect(
      (Canvas canvas) =>
          const TourSpotlightPainter(Rect.fromLTRB(200, 728, 400, 800))
              .paint(canvas, size),
      paints..something((method, arguments) {
        if (method != #drawRRect) return false;
        frame = arguments.first as RRect;
        return true;
      }),
    );

    // The 2 px stroke is centred on the frame, so it needs 1 px on each side.
    expect(frame!.right, lessThanOrEqualTo(size.width - 1));
    expect(frame!.bottom, lessThanOrEqualTo(size.height - 1));
    expect(frame!.left, 194);
    expect(frame!.top, 722);
  });

  testWidgets('Kembali returns to the previous step', (tester) async {
    await openHome(tester);
    await press(tester, 'Lanjut');
    await press(tester, 'Kembali');

    expect(find.text('1/6'), findsOneWidget);
  });

  testWidgets('Lewati closes it for good', (tester) async {
    await openHome(tester);
    await press(tester, 'Lewati');

    expect(_overlay, findsNothing);
    expect(store.done, contains(MockStore.profile.id));
  });

  testWidgets('blocks the page underneath', (tester) async {
    await openHome(tester);

    await tester.tapAt(const Offset(150, 860));
    await pumpFrames(tester, 5);

    expect(_overlay, findsOneWidget);
    expect(find.text('Katalog Daur Ulang'), findsNothing);
    expect(tester.widget<MainNavBar>(find.byType(MainNavBar)).currentIndex, 0);
  });

  testWidgets('the system back button skips it and keeps the app', (
    tester,
  ) async {
    await openHome(tester);

    await tester.binding.handlePopRoute();
    await pumpFrames(tester, 5);

    expect(_overlay, findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Profil can replay it', (tester) async {
    await store.markDone(MockStore.profile.id);
    await openHome(tester);
    await tester.tap(find.text('Profil'));
    await pumpFrames(tester);
    final tile = find.text('Lihat Panduan Aplikasi');
    for (var i = 0; i < 3 && tile.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -600));
      await pumpFrames(tester, 5);
    }
    await tester.ensureVisible(tile);
    await pumpFrames(tester, 5);

    await tester.tap(tile);
    await pumpFrames(tester);

    expect(_overlay, findsOneWidget);
    expect(find.text('1/6'), findsOneWidget);
    expect(tester.widget<MainNavBar>(find.byType(MainNavBar)).currentIndex, 0);
    expect(
      _hole(tester).contains(tester.getCenter(find.byType(BrushedMetal))),
      isTrue,
    );
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final english in [false, true]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        for (final still in [false, true]) {
          testWidgets('fits a small phone: ${theme.brightness.name}, '
              '${english ? 'EN' : 'ID'}, ${scale}x, still $still', (
            tester,
          ) async {
            MockStore.isEnglish.value = english;
            await openHome(
              tester,
              size: const Size(360, 640),
              theme: theme,
              scale: scale,
              still: still,
            );
            final screen = Offset.zero & const Size(360, 640);
            for (var i = 0; i < TourStep.home.length; i++) {
              final card = tester.getRect(
                find.byKey(const ValueKey('tour-card')),
              );
              expect(screen.contains(card.topLeft), isTrue);
              expect(card.bottom, lessThanOrEqualTo(640));
              expect(tester.takeException(), isNull);
              if (i < TourStep.home.length - 1) {
                final next = find.text(english ? 'Next' : 'Lanjut');
                await tester.ensureVisible(next);
                await tester.tap(next);
                await pumpFrames(tester, 8);
              }
            }
            final done = find.text(english ? 'Start' : 'Mulai');
            await tester.ensureVisible(done);
            await tester.tap(done);
            await pumpFrames(tester, 8);
            expect(_overlay, findsNothing);
          });
        }
      }
    }
  }
}
