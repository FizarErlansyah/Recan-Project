import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/home/presentation/mission_ring_card.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/screen.dart';

final Finder _burst = find.byKey(const ValueKey('reward-burst'));

void main() {
  late List<DailyQuest> seed;

  setUp(() => seed = List.of(MockStore.quests));
  tearDown(() {
    MockStore.quests.setAll(0, seed);
    MockStore.resetDemoState();
  });

  DailyQuest finish(int id) {
    final i = MockStore.quests.indexWhere((quest) => quest.id == id);
    return MockStore.quests[i] = MockStore.quests[i].withProgress(
      MockStore.quests[i].target,
    );
  }

  Future<void> open(WidgetTester tester, {bool still = false}) async {
    useTallPhone(tester);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: QuestPage(onLogout: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the mission progress', (tester) async {
    await open(tester);

    expect(find.byType(MissionRingCard), findsOneWidget);
  });

  testWidgets('a claimed mission celebrates its reward, then clears', (
    tester,
  ) async {
    final quest = finish(1);
    await open(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Klaim'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(
        of: _burst,
        matching: find.textContaining('+${quest.rewardPoints}'),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(_burst, findsNothing);
  });

  testWidgets('the daily reward celebrates too', (tester) async {
    await open(tester);

    await tester.tap(find.byKey(const ValueKey('checkin-claim')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(_burst, findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(_burst, findsNothing);
  });

  testWidgets('reduced motion gets the message without the burst', (
    tester,
  ) async {
    finish(1);
    await open(tester, still: true);

    await tester.tap(find.widgetWithText(FilledButton, 'Klaim'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_burst, findsNothing);
    expect(find.text('Misi berhasil diklaim!'), findsOneWidget);
  });

  testWidgets('fits large text on a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 2400);
    addTearDown(tester.view.reset);
    finish(1);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: QuestPage(onLogout: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
