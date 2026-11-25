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
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';

/// Everything the services need from a data source. [MockBackend] keeps the
/// app and its widget tests fully offline; `SupabaseBackend` talks to the real
/// project. Services stay the repository layer: they pick the backend and
/// announce changes, never touching a client directly.
abstract interface class AppBackend {
  /// True when data lives on a server, so demo shortcuts must stay off.
  bool get isRemote;

  bool get canEditEmail;

  Future<bool> restoreSession();

  Future<void> signIn({required String email, required String password});

  /// Returns false when the account exists but the email still needs to be
  /// confirmed, so there is no session yet.
  Future<bool> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> signOut();

  Future<ProfileData> profile();

  Future<ProfileOverview> overview();

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  });

  Future<void> connectGoPay();

  Future<AvatarRef> updateAvatar(String sourcePath);

  Future<AvatarRef> removeAvatar();

  Future<void> restoreAvatar();

  Future<DashboardData> dashboard();

  Future<List<MapStation>> stations();

  /// The station behind a scanned QR value, or null when it is unknown.
  Future<ScannedStation?> stationByQr(String code);

  Future<List<UpcycleProduct>> products();

  Future<List<Voucher>> vouchers();

  Future<List<OwnedVoucher>> ownedVouchers();

  /// Marks the caller's voucher as used at a partner counter.
  Future<void> useVoucher(String reference);

  Future<List<ActivityTransaction>> activities();

  Future<CarbonImpact> carbonImpact(CarbonRange range);

  /// [qrCode] is the scanned value; the server refuses a deposit without it.
  Future<void> submitDrop({
    required int cans,
    required int stationId,
    required String qrCode,
  });

  /// A null [channel] pays with points only, which then must cover the full
  /// price; otherwise the rupiah left after [pointsUsed] is paid through it.
  Future<PurchaseReceipt> redeemProduct({
    required int productId,
    required int quantity,
    required String shippingAddress,
    required int pointsUsed,
    PaymentChannel? channel,
    String? notes,
  });

  Future<String> redeemEWallet(EWalletOption option);

  Future<String> redeemVoucher(Voucher voucher);

  Future<GamificationData> gamification();

  /// Last known gamification state, shown while a refresh is in flight.
  GamificationData? get cachedGamification;

  Future<void> claimCheckIn();

  Future<void> claimQuest(int questId);

  Future<List<EducationArticle>> articles();

  /// Articles from the last load; synchronous so lists and related-article
  /// rows can build without waiting.
  List<EducationArticle> get cachedArticles;

  bool isBookmarked(int articleId);

  /// Flips the bookmark and returns the new state.
  bool toggleBookmark(int articleId);

  bool isBonusClaimed(int articleId);

  Future<void> claimArticleBonus(int articleId);
}

/// The backend every service talks to. Tests and offline runs keep the mock;
/// `main` swaps in Supabase once it is initialised.
abstract final class Backend {
  static AppBackend current = MockBackend();
}
