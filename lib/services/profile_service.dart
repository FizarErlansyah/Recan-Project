import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class ProfileService {
  const new _();

  static Future<ProfileData> fetchProfile() =>
      SynchronousFuture(MockStore.profile);

  static Future<void> updateProfile({
    required String name,
    required String email,
  }) {
    MockStore.updateProfile(name: name, email: email);
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }

  static Future<void> connectGoPay() {
    MockStore.connectGoPay();
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }

  static Future<List<LeaderboardEntry>> fetchLeaderboard() =>
      SynchronousFuture(MockStore.leaderboard);

  static Future<ProfileOverview> fetchOverview() => SynchronousFuture(
    ProfileOverview(
      profile: MockStore.profile,
      leaderboard: MockStore.leaderboard,
    ),
  );
}
