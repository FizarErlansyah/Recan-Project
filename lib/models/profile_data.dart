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

  /// Reads a `profiles` row. The caller adds `email` (auth) and
  /// `active_vouchers` (a count over `owned_vouchers`).
  factory fromJson(Map<String, dynamic> json) => ProfileData(
    id: json['id'] as String,
    name: json['full_name'] as String,
    email: json['email'] as String? ?? '',
    points: (json['points'] as num).toInt(),
    tier: json['tier'] as String,
    phone: json['phone'] as String? ?? '',
    gopayConnected: json['gopay_connected'] as bool? ?? false,
    activeVouchers: (json['active_vouchers'] as num?)?.toInt() ?? 0,
    avatar: AvatarRef(url: json['avatar_url'] as String?),
  );

  final String id;
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
    this.avatar = AvatarRef.none,
  });

  /// Reads a row of the `public_leaderboard` view.
  factory fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    rank: (json['rank'] as num).toInt(),
    name: json['full_name'] as String,
    totalKg: (json['total_kg'] as num).toDouble(),
    isCurrentUser: json['is_current_user'] as bool? ?? false,
    avatar: AvatarRef(url: json['avatar_url'] as String?),
  );

  final int rank;
  final String name;
  final double totalKg;
  final bool isCurrentUser;
  final AvatarRef avatar;

  String get initials => initialsOf(name);
}

class ProfileOverview {
  const new({required this.profile, required this.leaderboard});

  final ProfileData profile;
  final List<LeaderboardEntry> leaderboard;
}
