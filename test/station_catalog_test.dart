import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/pages/drop_station_map_page.dart';
import 'package:mobile_apps_recan/services/mock_stations.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/station_service.dart';
import 'package:mobile_apps_recan/widgets/station_tracking_section.dart';

void main() {
  group('station catalog', () {
    test(
      'covers public places around Greater Jakarta, not only the campus',
      () {
        final names = MockStations.mapStations.map((s) => s.name).join('|');

        for (final place in [
          'Jurang Mangu',
          'Bintaro Jaya Xchange',
          'AEON Mall BSD',
          'Taman Kota 1 BSD',
          'Rawa Buntu',
          'UPJ',
        ]) {
          expect(names, contains(place));
        }
      },
    );

    test('has unique ids and plausible Jabodetabek coordinates', () {
      final stations = MockStations.mapStations;

      expect(stations.map((s) => s.id).toSet(), hasLength(stations.length));
      for (final station in stations) {
        expect(station.position.latitude, inInclusiveRange(-6.6, -5.9));
        expect(station.position.longitude, inInclusiveRange(106.4, 107.2));
      }
    });

    test('keeps the Beranda list and the map on the same stations', () {
      final mapStations = MockStations.mapStations;
      final dropStations = MockStations.dropStations;

      expect(
        dropStations.map((s) => s.id).toList(),
        mapStations.map((s) => s.id).toList(),
      );
      expect(
        dropStations.map((s) => s.capacityPercentage).toList(),
        mapStations.map((s) => s.capacityPercent).toList(),
      );
      expect(MockStore.dropStations, same(MockStations.dropStations));
    });

    test('derives distances from coordinates so far stations rank last', () {
      final byDistance = [...MockStations.dropStations]
        ..sort((a, b) => a.distanceMeters!.compareTo(b.distanceMeters!));

      expect(byDistance.first.nameId, contains('Jurang Mangu'));
      expect(byDistance.last.nameId, contains('AEON Mall BSD'));
      expect(byDistance.last.distanceMeters, greaterThan(5000));
    });
  });

  group('map tiles stay light', () {
    testWidgets('Beranda preview ignores dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: StationTrackingSection(
                stations: MockStore.dropStations,
                onLogout: () {},
              ),
            ),
          ),
        ),
      );

      expect(
        tester.widget<TileLayer>(find.byType(TileLayer)).tileBuilder,
        isNull,
      );
    });

    testWidgets('Drop Station page ignores dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DropStationMapPage(onLogout: () {}),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<TileLayer>(find.byType(TileLayer)).tileBuilder,
        isNull,
      );
      expect(StationService.stations, isNotEmpty);
    });
  });
}
