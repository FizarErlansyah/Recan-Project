import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, per user and on this device, who has seen the app tour.
abstract interface class TourStore {
  static TourStore current = const PrefsTourStore();

  Future<bool> isDone(String userId);

  Future<void> markDone(String userId);
}

class PrefsTourStore implements TourStore {
  const new();

  static String _key(String userId) => 'home_tour_done_$userId';

  @override
  Future<bool> isDone(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  @override
  Future<void> markDone(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}
