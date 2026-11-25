import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/features/station/presentation/station_gate.dart';
import 'package:mobile_apps_recan/pages/drop_session_page.dart';
import 'package:mobile_apps_recan/pages/drop_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';

import 'support/recording_backend.dart';
import 'support/screen.dart';

ScannedStation _station({
  int current = 0,
  StationStatus status = StationStatus.available,
}) => ScannedStation(
  id: 204,
  name: 'Drop Station Stasiun Jurang Mangu',
  status: status,
  currentCans: current,
  maxCapacity: 300,
  qrCode: 'RECAN-ABC',
);

void main() {
  tearDown(() => Backend.current = MockBackend());

  group('scanned station', () {
    test('reads a station_by_qr row', () {
      final station = ScannedStation.fromJson(const {
        'id': 201,
        'name': 'Pasar',
        'name_en': 'Market',
        'status': 'available',
        'current_cans': 120,
        'max_capacity': 300,
      }, qrCode: 'RECAN-1');

      expect(station.remaining, 180);
      expect(station.qrCode, 'RECAN-1');
      expect(station.acceptsDeposits, isTrue);
    });

    test('full, maintenance, offline and no room all refuse deposits', () {
      for (final status in [
        StationStatus.full,
        StationStatus.maintenance,
        StationStatus.offline,
      ]) {
        expect(_station(status: status).acceptsDeposits, isFalse);
      }
      final packed = _station(current: 300);
      expect(packed.acceptsDeposits, isFalse);
      expect(packed.effectiveStatus, StationStatus.full);
    });

    test('an unknown status is treated as offline', () {
      expect(StationStatus.parse('???'), StationStatus.offline);
    });
  });

  group('station gate', () {
    Future<void> scan(WidgetTester tester, ScannedStation station) async {
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(StationGate.enter(context, station)),
              child: const Text('scan'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
    }

    for (final (status, title) in [
      (StationStatus.full, 'Station Penuh'),
      (StationStatus.maintenance, 'Station Dalam Perawatan'),
      (StationStatus.offline, 'Station Offline'),
    ]) {
      testWidgets('a $status station explains itself and stays out', (
        tester,
      ) async {
        await scan(tester, _station(status: status));

        expect(find.text(title), findsOneWidget);
        expect(find.byType(DropSessionPage), findsNothing);
      });
    }

    testWidgets('an available station opens the drop session', (tester) async {
      await scan(tester, _station(current: 10));

      expect(find.byType(DropSessionPage), findsOneWidget);
    });
  });

  group('drop session', () {
    Finder chip(String label) => find.widgetWithText(InkWell, label);
    bool enabled(WidgetTester tester, String label) =>
        tester.widget<InkWell>(chip(label)).onTap != null;
    final finish = find.byType(FilledButton);

    Future<void> open(WidgetTester tester, ScannedStation station) async {
      useTallPhone(tester);
      await tester.pumpWidget(testApp(DropSessionPage(station: station)));
    }

    testWidgets('offers +1, +5, +10 and +50 only', (tester) async {
      await open(tester, _station());

      for (final label in ['+1', '+5', '+10', '+50']) {
        expect(chip(label), findsOneWidget);
      }
      expect(find.textContaining('+1000'), findsNothing);
      expect(find.textContaining('300 dari 300'), findsOneWidget);
    });

    testWidgets('disables taps that would overfill the station', (
      tester,
    ) async {
      await open(tester, _station(current: 275));

      expect(enabled(tester, '+50'), isFalse);
      expect(enabled(tester, '+10'), isTrue);

      await tester.tap(chip('+10'));
      await tester.tap(chip('+10'));
      await tester.pumpAndSettle();
      expect(enabled(tester, '+10'), isFalse);
      expect(enabled(tester, '+5'), isTrue);

      await tester.tap(chip('+5'));
      await tester.pumpAndSettle();
      expect(enabled(tester, '+1'), isFalse);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      expect(find.textContaining('0 dari 300'), findsOneWidget);
    });

    testWidgets('sends the scanned QR with the deposit, once', (tester) async {
      final inFlight = Completer<void>();
      final backend = RecordingBackend(pending: inFlight.future);
      Backend.current = backend;
      await open(tester, _station());
      await tester.tap(chip('+5'));
      await tester.pumpAndSettle();

      await tester.tap(finish);
      await tester.pump();
      await tester.tap(finish, warnIfMissed: false);
      await tester.pump();

      expect(backend.calls, ['drop:5:204:RECAN-ABC']);
      expect(enabled(tester, '+1'), isFalse);
      inFlight.complete();
      await pumpFrames(tester);
      expect(find.byType(DropSuccessPage), findsOneWidget);
    });

    testWidgets('a station that turned full empties the session', (
      tester,
    ) async {
      Backend.current = RecordingBackend(
        dropFailure: const ApiException('Station sudah penuh.'),
        station: _station(current: 280, status: StationStatus.full),
      );
      await open(tester, _station());
      await tester.tap(chip('+10'));
      await tester.pumpAndSettle();

      await tester.tap(finish);
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
      expect(find.text('10'), findsNothing);
      expect(enabled(tester, '+1'), isFalse);
    });

    testWidgets('a refused deposit reloads the remaining room', (tester) async {
      Backend.current = RecordingBackend(
        dropFailure: const ApiException('Station sudah penuh.'),
        station: _station(current: 298),
      );
      await open(tester, _station());
      await tester.tap(chip('+50'));
      await tester.pumpAndSettle();

      await tester.tap(finish);
      await tester.pumpAndSettle();

      expect(find.text('Station sudah penuh.'), findsOneWidget);
      expect(find.textContaining('0 dari 300'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
