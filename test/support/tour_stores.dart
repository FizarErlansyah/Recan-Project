import 'package:mobile_apps_recan/features/tour/data/tour_store.dart';

/// Every user has seen the tour, so it stays out of unrelated tests.
class FinishedTourStore implements TourStore {
  const new();

  @override
  Future<bool> isDone(String userId) async => true;

  @override
  Future<void> markDone(String userId) async {}
}

class MemoryTourStore implements TourStore {
  final Set<String> done = {};

  @override
  Future<bool> isDone(String userId) async => done.contains(userId);

  @override
  Future<void> markDone(String userId) async => done.add(userId);
}
