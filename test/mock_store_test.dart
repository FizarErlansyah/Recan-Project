import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

void main() {
  test('seeds three quests for every period', () {
    for (final period in QuestPeriod.values) {
      final count = MockStore.quests.where((q) => q.period == period).length;
      expect(count, greaterThanOrEqualTo(3));
    }
  });

  test('depositing cans advances every unclaimed can quest', () {
    final before = MockStore.quests
        .where((q) => q.metric == QuestMetric.cans)
        .map((q) => q.progress)
        .toList();

    MockStore.recordDeposit(3);

    final after = MockStore.quests
        .where((q) => q.metric == QuestMetric.cans)
        .map((q) => q.progress)
        .toList();
    for (var i = 0; i < before.length; i++) {
      expect(after[i], before[i] + 3);
    }
  });

  test('claiming a completed quest adds its reward once', () {
    MockStore.recordDeposit(10);
    final quest = MockStore.quests.firstWhere((q) => q.canClaim);
    final pointsBefore = MockStore.points;

    expect(MockStore.claimQuest(quest.id), isTrue);
    expect(MockStore.points, pointsBefore + quest.rewardPoints);
    expect(MockStore.claimQuest(quest.id), isFalse);
  });

  test('helpful bonus is granted once per article', () async {
    final pointsBefore = MockStore.points;

    await EducationService.claimHelpfulBonus(1);
    expect(
      MockStore.points,
      pointsBefore + EducationService.helpfulBonusPoints,
    );

    await expectLater(EducationService.claimHelpfulBonus(1), throwsA(anything));
  });
}
