import 'package:flutter/foundation.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/avatar_store.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/education_catalog.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/services/mock_stations.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory data source: the demo data of [MockStore]. Futures complete
/// synchronously where they always did, so widgets paint their first frame
/// with data and tests need no server.
base class MockBackend implements AppBackend {
  static const String _mockToken = 'mock-session';

  @override
  bool get isRemote => false;

  @override
  bool get canEditEmail => true;

  @override
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException(
        tr(
          'Email dan kata sandi wajib diisi.',
          'Email and password are required.',
        ),
      );
    }
    MockStore.userEmail = email;
    MockStore.currentUsername = _displayNameOf(email);
    await _storeToken();
  }

  @override
  Future<bool> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      throw AuthException(
        tr('Semua kolom wajib diisi.', 'All fields are required.'),
      );
    }
    MockStore.currentUsername = fullName;
    MockStore.userEmail = email;
    MockStore.userPhone = phone;
    await _storeToken();
    return true;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
  }

  Future<void> _storeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, _mockToken);
  }

  static String _displayNameOf(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return MockStore.currentUsername;
    return local[0].toUpperCase() + local.substring(1);
  }

  @override
  Future<ProfileData> profile() => SynchronousFuture(MockStore.profile);

  @override
  Future<ProfileOverview> overview() => SynchronousFuture(
    ProfileOverview(
      profile: MockStore.profile,
      leaderboard: MockStore.leaderboard,
    ),
  );

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    MockStore.updateProfile(name: name, email: email, phone: phone);
    return SynchronousFuture(null);
  }

  @override
  Future<void> connectGoPay() {
    MockStore.connectGoPay();
    return SynchronousFuture(null);
  }

  @override
  Future<AvatarRef> updateAvatar(String sourcePath) async {
    MockStore.avatarPath = await AvatarStore.save(sourcePath);
    return MockStore.avatar;
  }

  @override
  Future<AvatarRef> removeAvatar() async {
    await AvatarStore.clear();
    MockStore.avatarPath = null;
    MockStore.avatarUrl = null;
    return MockStore.avatar;
  }

  @override
  Future<void> restoreAvatar() async {
    MockStore.avatarPath = await AvatarStore.load();
  }

  @override
  Future<DashboardData> dashboard() => SynchronousFuture(MockStore.dashboard);

  @override
  Future<List<MapStation>> stations() =>
      SynchronousFuture(MockStations.mapStations);

  @override
  Future<ScannedStation?> stationByQr(String code) {
    // Offline there is no QR registry, so any code opens the first station.
    final station = MockStations.dropStations.first;
    return SynchronousFuture(
      ScannedStation(
        id: station.id,
        name: station.nameId,
        nameEn: station.nameEn,
        status: StationStatus.parse(station.status),
        currentCans:
            station.capacityPercentage * ScannedStation.defaultCapacity ~/ 100,
        maxCapacity: ScannedStation.defaultCapacity,
        qrCode: code,
      ),
    );
  }

  @override
  Future<List<UpcycleProduct>> products() =>
      SynchronousFuture(List.unmodifiable(MockStore.products));

  @override
  Future<List<Voucher>> vouchers() =>
      SynchronousFuture(List.unmodifiable(MockStore.vouchers));

  @override
  Future<List<OwnedVoucher>> ownedVouchers() =>
      SynchronousFuture(List.unmodifiable(MockStore.ownedVouchers));

  @override
  Future<void> useVoucher(String reference) {
    final failure = MockStore.useVoucher(reference);
    if (failure != null) return Future.error(ApiException(failure));
    return SynchronousFuture(null);
  }

  @override
  Future<List<ActivityTransaction>> activities() =>
      SynchronousFuture(List.unmodifiable(MockStore.activities));

  @override
  Future<CarbonImpact> carbonImpact(CarbonRange range) =>
      SynchronousFuture(MockStore.carbonImpact(range));

  @override
  Future<void> submitDrop({
    required int cans,
    required int stationId,
    required String qrCode,
  }) {
    MockStore.recordDeposit(cans);
    return SynchronousFuture(null);
  }

  @override
  Future<PurchaseReceipt> redeemProduct({
    required int productId,
    required int quantity,
    required String shippingAddress,
    required int pointsUsed,
    PaymentChannel? channel,
    String? notes,
  }) {
    final result = MockStore.recordRedeem(
      productId: productId,
      quantity: quantity,
      pointsUsed: pointsUsed,
      channel: channel,
    );
    final failure = result.failure;
    if (failure != null) return Future.error(ApiException(failure));
    return SynchronousFuture(MockStore.activities.first.payment!);
  }

  @override
  Future<String> redeemEWallet(EWalletOption option) =>
      _settle(MockStore.recordEWalletRedeem(option));

  @override
  Future<String> redeemVoucher(Voucher voucher) =>
      _settle(MockStore.recordVoucherRedeem(voucher));

  Future<String> _settle(({String? failure, String? transactionId}) result) {
    final failure = result.failure;
    if (failure != null) return Future.error(ApiException(failure));
    return SynchronousFuture(result.transactionId!);
  }

  @override
  Future<GamificationData> gamification() =>
      SynchronousFuture(MockStore.gamification);

  @override
  GamificationData? get cachedGamification => MockStore.gamification;

  @override
  Future<void> claimCheckIn() {
    if (!MockStore.claimCheckIn()) {
      return Future.error(
        ApiException(
          tr(
            'Hadiah hari ini sudah diklaim.',
            'Your reward for today is already claimed.',
          ),
        ),
      );
    }
    return SynchronousFuture(null);
  }

  @override
  Future<void> claimQuest(int questId) {
    if (!MockStore.claimQuest(questId)) {
      return Future.error(
        ApiException(
          tr('Misi belum bisa diklaim.', 'Mission cannot be claimed yet.'),
        ),
      );
    }
    return SynchronousFuture(null);
  }

  @override
  Future<List<EducationArticle>> articles() =>
      SynchronousFuture(List.unmodifiable(EducationCatalog.articles));

  @override
  List<EducationArticle> get cachedArticles => EducationCatalog.articles;

  @override
  bool isBookmarked(int articleId) =>
      MockStore.bookmarkedArticleIds.contains(articleId);

  @override
  bool toggleBookmark(int articleId) {
    final saved = MockStore.bookmarkedArticleIds;
    if (!saved.remove(articleId)) saved.add(articleId);
    return saved.contains(articleId);
  }

  @override
  bool isBonusClaimed(int articleId) =>
      MockStore.helpfulClaimedArticleIds.contains(articleId);

  @override
  Future<void> claimArticleBonus(int articleId) {
    if (!MockStore.claimHelpfulBonus(
      articleId,
      EducationService.helpfulBonusPoints,
    )) {
      return Future.error(
        ApiException(
          tr(
            'Bonus artikel ini sudah kamu klaim.',
            'You already claimed the bonus for this article.',
          ),
        ),
      );
    }
    return SynchronousFuture(null);
  }
}
