import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/weight_format.dart';
import 'package:mobile_apps_recan/widgets/drop_estimate_card.dart';

void main() {
  tearDown(() => MockStore.isEnglish.value = false);

  group('formatWeight in Indonesian', () {
    test('stays in grams below one kilogram', () {
      expect(formatWeight(0), '0 g');
      expect(formatWeight(14), '14 g');
      expect(formatWeight(140), '140 g');
      expect(formatWeight(999), '999 g');
    });

    test('rounds fractional grams', () {
      expect(formatWeight(14.4), '14 g');
      expect(formatWeight(0.014 * 1000), '14 g');
    });

    test('switches to kilograms at exactly 1000 g without a zero decimal', () {
      expect(formatWeight(1000), '1 kg');
      expect(formatWeight(999.6), '1 kg');
    });

    test('keeps up to two decimals and drops trailing zeros', () {
      expect(formatWeight(1500), '1,5 kg');
      expect(formatWeight(1250), '1,25 kg');
      expect(formatWeight(1004), '1 kg');
      expect(formatWeight(2030), '2,03 kg');
    });

    test('groups thousands of kilograms', () {
      expect(formatWeight(1234567), '1.234,57 kg');
    });
  });

  group('formatWeight in English', () {
    setUp(() => MockStore.isEnglish.value = true);

    test('uses the same unit for grams', () {
      expect(formatWeight(14), '14 g');
      expect(formatWeight(140), '140 g');
    });

    test('uses a dot decimal and comma thousands in kilograms', () {
      expect(formatWeight(1000), '1 kg');
      expect(formatWeight(1500), '1.5 kg');
      expect(formatWeight(1250), '1.25 kg');
      expect(formatWeight(1234567), '1,234.57 kg');
    });
  });

  testWidgets('drop estimate card shows one can as 14 g', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DropEstimateCard(summary: DropSessionSummary(cans: 1)),
        ),
      ),
    );

    expect(find.text('14 g'), findsOneWidget);
  });

  testWidgets('drop estimate card shows 100 cans as 1,4 kg', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DropEstimateCard(summary: DropSessionSummary(cans: 100)),
        ),
      ),
    );

    expect(find.text('1,4 kg'), findsOneWidget);
  });
}
