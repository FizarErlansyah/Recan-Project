import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/utils/initials.dart';

class ProfileData {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.tier,
    required this.phone,
    required this.gopayConnected,
    required this.activeVouchers,
    this.avatar = AvatarRef.none,
  });

  final int id;
  final String name;
  final String email;
  final int points;
  final String tier;
  final String phone;
  final bool gopayConnected;
  final int activeVouchers;
  final AvatarRef avatar;

  String get initials => initialsOf(name);
}

class LeaderboardEntry {
  const new({
    required this.rank,
    required this.name,
    required this.totalKg,
    required this.isCurrentUser,
  });

  factory fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    rank: json['rank'] as int,
    name: json['name'] as String,
    totalKg: (json['total_kg'] as num).toDouble(),
    isCurrentUser: json['is_current_user'] as bool,
  );

  final int rank;
  final String name;
  final double totalKg;
  final bool isCurrentUser;
}

class ProfileOverview {
  const new({required this.profile, required this.leaderboard});

  final ProfileData profile;
  final List<LeaderboardEntry> leaderboard;
}
