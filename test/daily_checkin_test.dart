import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/rewards/domain/wib_calendar.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

import 'support/recording_backend.dart';
import 'support/screen.dart';

const _rewards = [10, 20, 30, 50, 75, 100, 200];

/// An instant given as Jakarta wall-clock time.
DateTime _wib(int day, [int hour = 12, int minute = 0]) =>
    DateTime.utc(2026, 11, day, hour - 7, minute);

void main() {
  tearDown(() {
    Backend.current = MockBackend();
    MockStore.resetDemoState();
  });

  group('Jakarta calendar', () {
    test('the day changes at 00:00 WIB, not at UTC midnight', () {
      expect(WibCalendar.dayOf(_wib(25, 23, 59)), DateTime.utc(2026, 11, 25));
      expect(WibCalendar.dayOf(_wib(26, 0)), DateTime.utc(2026, 11, 26));
    });

    test('the next reset is the coming Jakarta midnight', () {
      expect(WibCalendar.nextMidnight(_wib(25, 23, 59)), _wib(26, 0));
      expect(WibCalendar.nextMidnight(_wib(26, 0)), _wib(27, 0));
    });
  });

  group('non-resetting check-in', () {
    DailyCheckIn state(DateTime now) => MockStore.checkInAt(now);

    test('a new account starts at day 1 on any weekday', () {
      for (var day = 23; day <= 29; day++) {
        final checkIn = state(_wib(day));
        expect(checkIn.claimedCount, 0);
        expect(checkIn.currentDay, 0);
        expect(checkIn.claimedToday, isFalse);
        expect(checkIn.nextClaimAt, isNull);
      }
    });

    test('only one claim per Jakarta day', () {
      expect(MockStore.claimCheckIn(_wib(10, 0, 5)), isTrue);
      expect(MockStore.claimCheckIn(_wib(10, 23, 55)), isFalse);
      expect(state(_wib(10, 23, 55)).nextClaimAt, _wib(11, 0));
      expect(MockStore.claimCheckIn(_wib(11, 0, 1)), isTrue);
    });

    test('skipped days keep the progress', () {
      MockStore.claimCheckIn(_wib(10));

      final later = state(_wib(15));

      expect(later.claimedCount, 1);
      expect(later.currentDay, 1);
      expect(later.todayReward, 20);
    });

    test('claiming adds the reward of the cycle day', () {
      final before = MockStore.points;
      MockStore.claimCheckIn(_wib(10));
      MockStore.claimCheckIn(_wib(14));

      expect(MockStore.points, before + _rewards[0] + _rewards[1]);
    });

    test('the cycle restarts the day after day 7 is claimed', () {
      for (var day = 1; day <= 7; day++) {
        expect(MockStore.claimCheckIn(_wib(day * 2)), isTrue);
      }

      final sameDay = state(_wib(14));
      expect(sameDay.claimedCount, 7);
      expect(sameDay.currentDay, 6);

      final nextDay = state(_wib(15));
      expect(nextDay.claimedCount, 0);
      expect(nextDay.currentDay, 0);
    });

    test('a server row reads progress and the next reset', () {
      final checkIn = DailyCheckIn.fromJson({
        'claimed_count': 2,
        'claimed_today': true,
        'next_claim_at': '2026-11-25T17:00:00+00:00',
        'rewards': _rewards,
      });

      expect(checkIn.currentDay, 1);
      expect(checkIn.isClaimed(0), isTrue);
      expect(checkIn.isClaimed(1), isTrue);
      expect(checkIn.isClaimed(2), isFalse);
      expect(checkIn.nextClaimAt, _wib(26, 0));
    });
  });

  group('quest reset wording', () {
    test('every period names its Jakarta boundary', () {
      expect(QuestPeriod.daily.resetLabel, contains('00:00 WIB'));
      expect(QuestPeriod.weekly.resetLabel, contains('Senin'));
      expect(QuestPeriod.monthly.resetLabel, contains('tanggal 1'));
    });
  });

  group('Misi & Hadiah check-in card', () {
    Finder slot(int index, {required bool done}) =>
        find.byKey(ValueKey('checkin-$index-${done ? 'done' : 'open'}'));

    testWidgets('shows days 1..N ticked and when the next claim opens', (
      tester,
    ) async {
      useTallPhone(tester);
      Backend.current = RecordingBackend(
        checkIn: DailyCheckIn(
          rewards: _rewards,
          claimedCount: 3,
          claimedToday: true,
          nextClaimAt: _wib(26, 0),
        ),
      );

      await tester.pumpWidget(testApp(QuestPage(onLogout: () {})));
      await tester.pumpAndSettle();

      for (var i = 0; i < 7; i++) {
        expect(slot(i, done: i < 3), findsOneWidget, reason: 'day ${i + 1}');
      }
      expect(find.textContaining('26 Nov'), findsOneWidget);
      expect(find.textContaining('00:00 WIB'), findsWidgets);
    });

    testWidgets('a fresh account is offered day 1', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(testApp(QuestPage(onLogout: () {})));
      await tester.pumpAndSettle();

      expect(slot(0, done: false), findsOneWidget);
      expect(find.text('Klaim Hari 1: +10 Poin'), findsOneWidget);
    });

    testWidgets('a double tap sends one claim', (tester) async {
      useTallPhone(tester);
      final inFlight = Completer<void>();
      final backend = RecordingBackend(
        pending: inFlight.future,
        checkIn: const DailyCheckIn(
          rewards: _rewards,
          claimedCount: 0,
          claimedToday: false,
        ),
      );
      Backend.current = backend;
      await tester.pumpWidget(testApp(QuestPage(onLogout: () {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Klaim Hari 1: +10 Poin'));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('checkin-claim')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(backend.calls, ['claimCheckIn']);
      inFlight.complete();
      await tester.pumpAndSettle();
    });
  });
}
