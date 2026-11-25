import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/supabase_errors.dart';
import 'package:mobile_apps_recan/services/backend/supabase_realtime.dart';
import 'package:mobile_apps_recan/services/station_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// The real data source. Every write goes through an RPC function, so points,
/// stock and station counters are decided on the server; reads rely on Row
/// Level Security to return only what the signed-in user may see.
class SupabaseBackend implements AppBackend {
  new(SupabaseClient client)
    : _client = client,
      _realtime = SupabaseRealtime(client) {
    _client.auth.onAuthStateChange.listen(_handleAuthChange);
  }

  static const String _avatarBucket = 'avatars';
  static const String _avatarFile = 'avatar.jpg';
  static const int _activityLimit = 100;
  static const int _leaderboardLimit = 10;
  // The local session is already gone when the server call runs, so a slow
  // network must not hold the logout screen.
  static const Duration _signOutTimeout = Duration(seconds: 8);

  final SupabaseClient _client;
  final SupabaseRealtime _realtime;

  GamificationData? _gamification;
  List<EducationArticle> _articles = const [];
  final Set<int> _bookmarks = {};
  final Set<int> _bonusClaims = {};

  @override
  bool get isRemote => true;

  // Changing the sign-in email needs a confirmation round-trip that the Edit
  // Profil form does not model yet, so the field stays read-only.
  @override
  bool get canEditEmail => false;

  void _handleAuthChange(AuthState state) {
    final user = state.session?.user;
    if (user != null) {
      _realtime.start(user.id);
    } else {
      _clearSessionData();
    }
  }

  void _clearSessionData() {
    unawaited(_realtime.stop());
    _gamification = null;
    _articles = const [];
    _bookmarks.clear();
    _bonusClaims.clear();
  }

  User get _user {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ApiException(
        tr(
          'Sesi kamu berakhir. Silakan masuk lagi.',
          'Your session has expired. Please log in again.',
        ),
        unauthorized: true,
      );
    }
    return user;
  }

  /// Runs [body] and converts any failure into an [ApiException].
  Future<T> _guard<T>(
    Future<T> Function() body, {
    String? alreadyClaimed,
  }) async {
    try {
      return await body();
    } on Object catch (error) {
      throw SupabaseErrors.api(error, alreadyClaimed: alreadyClaimed);
    }
  }

  List<Map<String, dynamic>> _rows(Object? data) =>
      List<Map<String, dynamic>>.from(data! as List<dynamic>);

  @override
  Future<bool> restoreSession() async {
    final session = _client.auth.currentSession;
    if (session != null) _realtime.start(session.user.id);
    return session != null;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on Object catch (error) {
      throw SupabaseErrors.auth(error);
    }
  }

  @override
  Future<bool> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'full_name': fullName, 'phone': phone},
      );
    } on Object catch (error) {
      throw SupabaseErrors.auth(error);
    }
    // With email confirmation on, Supabase hides "already registered" and
    // returns a user without identities instead of an error.
    if (response.user?.identities?.isEmpty ?? false) {
      throw AuthException(
        tr(
          'Email ini sudah terdaftar. Silakan masuk.',
          'This email is already registered. Please log in.',
        ),
      );
    }
    return response.session != null;
  }

  @override
  Future<void> signOut() async {
    _clearSessionData();
    try {
      await _client.auth.signOut().timeout(_signOutTimeout);
    } on Object catch (error) {
      debugPrint('Sign-out request failed: $error');
    }
  }

  Future<Map<String, dynamic>> _profileRow() async {
    final user = _user;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return {...row, 'email': user.email};
  }

  @override
  Future<ProfileData> profile() => _guard(() async {
    final row = await _profileRow();
    final vouchers = await _client
        .from('owned_vouchers')
        .select('id')
        .eq('user_id', _user.id)
        .eq('status', 'active');
    return ProfileData.fromJson({...row, 'active_vouchers': vouchers.length});
  });

  @override
  Future<ProfileOverview> overview() => _guard(() async {
    final results = await Future.wait<Object?>([profile(), _leaderboard()]);
    return ProfileOverview(
      profile: results[0]! as ProfileData,
      leaderboard: results[1]! as List<LeaderboardEntry>,
    );
  });

  Future<List<LeaderboardEntry>> _leaderboard() async {
    final rows = _rows(
      await _client
          .from('public_leaderboard')
          .select()
          .limit(_leaderboardLimit),
    );
    if (!rows.any((row) => row['is_current_user'] == true)) {
      rows.addAll(
        _rows(
          await _client
              .from('public_leaderboard')
              .select()
              .eq('is_current_user', true)
              .limit(1),
        ),
      );
    }
    return [for (final row in rows) LeaderboardEntry.fromJson(row)];
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) => _guard(() async {
    await _client
        .from('profiles')
        .update({'full_name': name, 'phone': phone})
        .eq('id', _user.id);
  });

  @override
  Future<void> connectGoPay() => _guard(() async {
    await _client
        .from('profiles')
        .update({'gopay_connected': true})
        .eq('id', _user.id);
  });

  @override
  Future<AvatarRef> updateAvatar(String sourcePath) => _guard(() async {
    final uid = _user.id;
    final path = '$uid/$_avatarFile';
    final bytes = await File(sourcePath).readAsBytes();
    final storage = _client.storage.from(_avatarBucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: _contentTypeOf(sourcePath),
      ),
    );
    // The path never changes, so the timestamp is what makes every widget
    // fetch the new picture instead of the cached one.
    final url =
        '${storage.getPublicUrl(path)}'
        '?t=${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('profiles').update({'avatar_url': url}).eq('id', uid);
    return AvatarRef(url: url);
  });

  @override
  Future<AvatarRef> removeAvatar() => _guard(() async {
    final uid = _user.id;
    await _client.storage.from(_avatarBucket).remove(['$uid/$_avatarFile']);
    await _client.from('profiles').update({'avatar_url': null}).eq('id', uid);
    return AvatarRef.none;
  });

  // The photo lives on the server and arrives with the profile row.
  @override
  Future<void> restoreAvatar() async {}

  static String _contentTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<List<Map<String, dynamic>>> _stationRows() async {
    final data = await _client.rpc<dynamic>(
      'stations_with_distance',
      params: {
        'p_lat': StationService.userPosition.latitude,
        'p_lng': StationService.userPosition.longitude,
      },
    );
    return _rows(data);
  }

  Future<List<Map<String, dynamic>>> _catalogRows(String type) async {
    final data = await _client
        .from('catalog_items')
        .select()
        .eq('item_type', type)
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return _rows(data);
  }

  @override
  Future<DashboardData> dashboard() => _guard(() async {
    final results = await Future.wait<Object?>([
      _profileRow(),
      _stationRows(),
      _catalogRows('product'),
      // Warms the article cache so the featured row can build synchronously.
      articles(),
    ]);
    return DashboardData(
      user: UserProfile.fromJson(results[0]! as Map<String, dynamic>),
      dropStations: [
        for (final row in results[1]! as List<Map<String, dynamic>>)
          DropStation.fromJson(row),
      ],
      products: [
        for (final row in results[2]! as List<Map<String, dynamic>>)
          UpcycleProduct.fromJson(row),
      ],
    );
  });

  @override
  Future<List<MapStation>> stations() => _guard(() async {
    final rows = await _stationRows();
    return [for (final row in rows) MapStation.fromJson(row)];
  });

  @override
  Future<ScannedStation?> stationByQr(String code) => _guard(() async {
    final qrCode = code.trim();
    final rows = _rows(
      await _client.rpc<dynamic>(
        'station_by_qr',
        params: {'p_qr_code': qrCode},
      ),
    );
    return rows.isEmpty
        ? null
        : ScannedStation.fromJson(rows.first, qrCode: qrCode);
  });

  @override
  Future<List<UpcycleProduct>> products() => _guard(() async {
    final rows = await _catalogRows('product');
    return [for (final row in rows) UpcycleProduct.fromJson(row)];
  });

  @override
  Future<List<Voucher>> vouchers() => _guard(() async {
    final rows = await _catalogRows('voucher');
    return [for (final row in rows) Voucher.fromJson(row)];
  });

  @override
  Future<List<OwnedVoucher>> ownedVouchers() => _guard(() async {
    final data = await _client
        .from('owned_vouchers')
        .select('*, catalog_items(*)')
        .eq('user_id', _user.id)
        .eq('status', 'active')
        .order('redeemed_at', ascending: false);
    return [for (final row in _rows(data)) OwnedVoucher.fromJson(row)];
  });

  @override
  Future<List<ActivityTransaction>> activities() => _guard(() async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', _user.id)
        .order('created_at', ascending: false)
        .limit(_activityLimit);
    return [for (final row in _rows(data)) ActivityTransaction.fromJson(row)];
  });

  @override
  Future<CarbonImpact> carbonImpact(CarbonRange range) => _guard(() async {
    final data = await _client
        .from('community_carbon_summary')
        .select()
        .eq('range_key', range.name)
        .order('bucket_index', ascending: true);
    return CarbonImpact.fromSummary(range, _rows(data));
  });

  @override
  Future<void> submitDrop({
    required int cans,
    required int stationId,
    required String qrCode,
  }) => _guard(() async {
    await _client.rpc<dynamic>(
      'record_can_deposit',
      params: {
        'p_station_id': stationId,
        'p_cans_count': cans,
        'p_qr_code': qrCode,
      },
    );
  });

  /// Without payment parameters the server charges the full point price.
  Future<Map<String, dynamic>> _redeem(
    int itemId, [
    Map<String, Object?> order = const {},
  ]) async {
    final data = await _client.rpc<dynamic>(
      'redeem_reward',
      params: {'p_item_id': itemId, ...order},
    );
    return _rows(data).first;
  }

  @override
  Future<PurchaseReceipt> redeemProduct({
    required int productId,
    required int quantity,
    required String shippingAddress,
    required int pointsUsed,
    PaymentChannel? channel,
    String? notes,
  }) => _guard(() async {
    final row = await _redeem(productId, {
      'p_quantity': quantity,
      'p_shipping_address': shippingAddress,
      'p_notes': notes,
      'p_payment_method': PaymentMode.of(
        pointsUsed: pointsUsed,
        paysCash: channel != null,
      ).name,
      'p_points_used': pointsUsed,
      'p_payment_channel': channel?.code,
    });
    return PurchaseReceipt.fromRedeemRow(row);
  });

  @override
  Future<String> redeemEWallet(EWalletOption option) => _guard(() async {
    final row = await _client
        .from('catalog_items')
        .select('id')
        .eq('item_type', 'ewallet')
        .eq('ewallet_provider', option.provider)
        .eq('ewallet_nominal', option.nominal)
        .eq('is_active', true)
        .maybeSingle();
    if (row == null) {
      throw ApiException(tr('Item tidak ditemukan.', 'Item not found.'));
    }
    final order = await _redeem(row['id'] as int);
    return order['reference'] as String;
  });

  @override
  Future<String> redeemVoucher(Voucher voucher) => _guard(() async {
    final order = await _redeem(voucher.id);
    return order['reference'] as String;
  });

  @override
  Future<GamificationData> gamification() => _guard(() async {
    final results = await Future.wait<Object?>([
      _client.from('my_quest_status').select().order('id', ascending: true),
      _client.rpc<dynamic>('my_checkin_state'),
    ]);
    final data = GamificationData(
      dailyQuests: [
        for (final row in _rows(results[0])) DailyQuest.fromJson(row),
      ],
      checkIn: DailyCheckIn.fromJson(_rows(results[1]).single),
    );
    return _gamification = data;
  });

  @override
  GamificationData? get cachedGamification => _gamification;

  @override
  Future<void> claimCheckIn() => _guard(
    () async {
      await _client.rpc<dynamic>('claim_daily_checkin');
    },
    alreadyClaimed: tr(
      'Hadiah hari ini sudah diklaim.',
      'Your reward for today is already claimed.',
    ),
  );

  @override
  Future<void> claimQuest(int questId) => _guard(
    () async {
      await _client.rpc<dynamic>(
        'claim_quest',
        params: {'p_quest_id': questId},
      );
    },
    alreadyClaimed: tr(
      'Misi ini sudah diklaim.',
      'This mission is already claimed.',
    ),
  );

  @override
  Future<List<EducationArticle>> articles() => _guard(() async {
    final results = await Future.wait<Object?>([
      _client
          .from('education_articles')
          .select()
          .eq('is_published', true)
          .order('id', ascending: true),
      // Both tables are limited to the caller's own rows by RLS.
      _client.from('article_bookmarks').select('article_id'),
      _client.from('article_bonus_claims').select('article_id'),
    ]);
    final rows = _rows(results[0]);
    final bookmarks = _rows(results[1]);
    final claims = _rows(results[2]);

    _articles = [for (final row in rows) EducationArticle.fromJson(row)];
    _bookmarks
      ..clear()
      ..addAll(bookmarks.map((row) => (row['article_id'] as num).toInt()));
    _bonusClaims
      ..clear()
      ..addAll(claims.map((row) => (row['article_id'] as num).toInt()));
    return List.unmodifiable(_articles);
  });

  @override
  List<EducationArticle> get cachedArticles => _articles;

  @override
  bool isBookmarked(int articleId) => _bookmarks.contains(articleId);

  @override
  bool toggleBookmark(int articleId) {
    final saved = _bookmarks.add(articleId);
    if (!saved) _bookmarks.remove(articleId);
    unawaited(_persistBookmark(articleId, saved: saved));
    return saved;
  }

  // The toggle answers instantly; a failed write rolls the local state back so
  // the next screen does not show a bookmark the server never stored.
  Future<void> _persistBookmark(int articleId, {required bool saved}) async {
    try {
      final table = _client.from('article_bookmarks');
      if (saved) {
        await table.upsert({'user_id': _user.id, 'article_id': articleId});
      } else {
        await table
            .delete()
            .eq('user_id', _user.id)
            .eq('article_id', articleId);
      }
    } on Object catch (error) {
      debugPrint('Bookmark sync failed: $error');
      if (saved) {
        _bookmarks.remove(articleId);
      } else {
        _bookmarks.add(articleId);
      }
    }
  }

  @override
  bool isBonusClaimed(int articleId) => _bonusClaims.contains(articleId);

  @override
  Future<void> claimArticleBonus(int articleId) => _guard(
    () async {
      await _client.rpc<dynamic>(
        'claim_article_bonus',
        params: {'p_article_id': articleId},
      );
      _bonusClaims.add(articleId);
    },
    alreadyClaimed: tr(
      'Bonus artikel ini sudah kamu klaim.',
      'You already claimed the bonus for this article.',
    ),
  );
}
