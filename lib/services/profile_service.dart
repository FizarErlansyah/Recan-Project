import 'package:flutter/foundation.dart';

import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/avatar_store.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

class ProfileService {
  const new _();

  static Future<ProfileData> fetchProfile() =>
      SynchronousFuture(MockStore.profile);

  static Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    MockStore.updateProfile(name: name, email: email, phone: phone);
    DataRefresh.notifyChanged();
    return SynchronousFuture(null);
  }

  // The photo is only stored on the device for now. When Supabase Storage is
  // wired in, upload here and set MockStore.avatarUrl; the screens already
  // read an AvatarRef, so none of them change.
  static Future<AvatarRef> updateAvatar(String sourcePath) async {
    MockStore.avatarPath = await AvatarStore.save(sourcePath);
    DataRefresh.notifyChanged();
    return MockStore.avatar;
  }

  static Future<AvatarRef> removeAvatar() async {
    await AvatarStore.clear();
    MockStore.avatarPath = null;
    MockStore.avatarUrl = null;
    DataRefresh.notifyChanged();
    return MockStore.avatar;
  }

  static Future<void> restoreAvatar() async {
    MockStore.avatarPath = await AvatarStore.load();
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
