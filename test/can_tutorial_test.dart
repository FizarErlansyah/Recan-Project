import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/tutorial/domain/can_tutorial.dart';
import 'package:mobile_apps_recan/features/tutorial/presentation/can_tutorial_page.dart';
import 'package:mobile_apps_recan/pages/edukasi_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/screen.dart';

void main() {
  tearDown(() => MockStore.isEnglish.value = false);

  const steps = CanTutorial.steps;

  test('every step is written in both languages', () {
    expect(steps.length, greaterThanOrEqualTo(5));
    for (final step in steps) {
      for (final text in [
        step.titleId,
        step.titleEn,
        step.bodyId,
        step.bodyEn,
      ]) {
        expect(text.trim(), isNotEmpty);
      }
      expect(step.safetyId == null, step.safetyEn == null);
    }
  });

  test('every step that cuts or sands carries a safety note', () {
    final risky = steps.where((step) {
      final body = step.bodyId.toLowerCase();
      return body.contains('potong melingkar') || body.contains('amplas');
    });

    expect(risky, isNotEmpty);
    expect(risky.every((step) => step.safetyId != null), isTrue);
  });

  test('no step capitalises a word in the middle of a sentence', () {
    final stray = RegExp('[a-z,] Potong');

    expect(steps.where((step) => stray.hasMatch(step.bodyId)), isEmpty);
  });

  testWidgets('Edukasi opens the tutorial', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(testApp(const EdukasiPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutorial Olah Kaleng'));
    await tester.pumpAndSettle();

    expect(find.byType(CanTutorialPage), findsOneWidget);
  });

  testWidgets('walks forward, back and out', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => CanTutorialPage.open(context),
            child: const Text('buka'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    expect(find.text('Langkah 1 dari ${steps.length}'), findsOneWidget);
    expect(find.text('Kembali'), findsNothing);

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text(steps[1].titleId), findsOneWidget);

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text(steps[0].titleId), findsOneWidget);

    for (var i = 1; i < steps.length; i++) {
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(find.byType(CanTutorialPage), findsNothing);
  });

  testWidgets('speaks English', (tester) async {
    MockStore.isEnglish.value = true;
    useTallPhone(tester);
    await tester.pumpWidget(testApp(const CanTutorialPage()));
    await tester.pumpAndSettle();

    expect(find.text(steps.first.titleEn), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('fits large text on a narrow phone, every step', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 740);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.6),
              disableAnimations: true,
            ),
            child: const CanTutorialPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 1; i < steps.length; i++) {
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Selesai'), findsOneWidget);
  });
}
