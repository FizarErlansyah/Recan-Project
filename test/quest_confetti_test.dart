import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/screen.dart';

void main() {
  late List<DailyQuest> seed;

  setUp(() => seed = List.of(MockStore.quests));
  tearDown(() {
    MockStore.quests.setAll(0, seed);
    MockStore.resetDemoState();
  });

  void put(int id, {required bool claimed}) {
    final i = MockStore.quests.indexWhere((quest) => quest.id == id);
    final done = MockStore.quests[i].withProgress(MockStore.quests[i].target);
    MockStore.quests[i] = claimed ? done.claimed() : done;
  }

  int playing(WidgetTester tester) => tester
      .widgetList<ConfettiWidget>(find.byType(ConfettiWidget))
      .where(
        (widget) =>
            widget.confettiController.state == ConfettiControllerState.playing,
      )
      .length;

  Future<void> open(WidgetTester tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(testApp(QuestPage(onLogout: () {})));
    await tester.pumpAndSettle();
  }

  testWidgets('opening the page with claimed quests stays quiet', (
    tester,
  ) async {
    put(1, claimed: true);
    await open(tester);

    expect(playing(tester), 0);
  });

  testWidgets('switching period tabs never fires confetti', (tester) async {
    put(1, claimed: false);
    put(4, claimed: true);
    put(7, claimed: true);
    await open(tester);

    for (final tab in ['Mingguan', 'Bulanan', 'Harian', 'Mingguan']) {
      await tester.tap(find.text(tab));
      await tester.pump(const Duration(milliseconds: 100));
      expect(playing(tester), 0, reason: 'after switching to $tab');
      await tester.pumpAndSettle();
    }
  });

  testWidgets('a successful claim celebrates once', (tester) async {
    put(1, claimed: false);
    await open(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Klaim'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(playing(tester), 1);

    // Particles age on the wall clock, which a widget test does not advance,
    // so the burst is ended by hand before looking for a second one.
    for (final widget in tester.widgetList<ConfettiWidget>(
      find.byType(ConfettiWidget),
    )) {
      widget.confettiController.stop(clearAllParticles: true);
    }
    await tester.pump(const Duration(seconds: 2));
    DataRefresh.notifyChanged();
    await tester.pump(const Duration(milliseconds: 100));
    expect(playing(tester), 0, reason: 'a reload is not a new claim');

    await tester.tap(find.text('Mingguan'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Harian'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(playing(tester), 0, reason: 'coming back is not a new claim');
    await tester.pumpAndSettle();
  });

  testWidgets('a rejected claim does not celebrate', (tester) async {
    put(1, claimed: false);
    await open(tester);
    put(1, claimed: true);

    await tester.tap(find.widgetWithText(FilledButton, 'Klaim'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(playing(tester), 0);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
