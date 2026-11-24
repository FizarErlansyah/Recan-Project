import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/models/ewallet_option.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/models/member_tier.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/services/mock_stations.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class MockStore {
  const new _();

  static const int initialPoints = 0;
  static const int demoPointsGrant = 25000;
  static const String _userId = 'local-user';
  static const String _idAlphabet = '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static final Random _random = Random();

  static final ValueNotifier<bool> isEnglish = ValueNotifier(false);
  static final Set<int> bookmarkedArticleIds = {};
  static final Set<int> helpfulClaimedArticleIds = {};
  static String currentUsername = 'Guest';
  static String userPhone = '0812-3456-7890';
  static bool gopayConnected = false;
  static const List<int> checkInRewards = [10, 20, 30, 50, 75, 100, 200];
  static final Set<int> _claimedCheckInDays = {
    for (var i = 0; i < DateTime.now().weekday - 1; i++) i,
  };
  static String userEmail = 'guest@recan.id';
  static String? avatarPath;
  static String? avatarUrl;
  static int points = initialPoints;
  static int streakDays = 5;
  static double depositedKg = 0;
  static int userTotalCans = 0;
  static int userTodayCans = 0;

  static final List<ActivityTransaction> activities = [];
  static final List<OwnedVoucher> ownedVouchers = [];

  static final List<DailyQuest> quests = [
    const DailyQuest(
      id: 1,
      title: 'Setor 5 Kaleng Hari Ini',
      titleEn: 'Drop 5 Cans Today',
      progress: 2,
      target: 5,
      unit: 'Kaleng',
      unitEn: 'Cans',
      rewardPoints: 50,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 2,
      title: 'Setor 10 Kaleng Hari Ini',
      titleEn: 'Drop 10 Cans Today',
      progress: 2,
      target: 10,
      unit: 'Kaleng',
      unitEn: 'Cans',
      rewardPoints: 150,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 3,
      metric: QuestMetric.checkIn,
      title: 'Klaim Hadiah Harian',
      titleEn: 'Claim the Daily Reward',
      progress: 0,
      target: 1,
      unit: 'Klaim',
      unitEn: 'Claim',
      rewardPoints: 20,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 4,
      period: QuestPeriod.weekly,
      title: 'Setor 15 Kaleng Minggu Ini',
      titleEn: 'Drop 15 Cans This Week',
      progress: 5,
      target: 15,
      unit: 'Kaleng',
      unitEn: 'Cans',
      rewardPoints: 200,
      isClaimed: false,
    ),
    DailyQuest(
      id: 5,
      period: QuestPeriod.weekly,
      metric: QuestMetric.checkIn,
      title: 'Klaim 3 Hadiah Harian',
      titleEn: 'Claim 3 Daily Rewards',
      progress: _claimedCheckInDays.length,
      target: 3,
      unit: 'Klaim',
      unitEn: 'Claims',
      rewardPoints: 120,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 6,
      period: QuestPeriod.weekly,
      metric: QuestMetric.voucher,
      title: 'Tukar 1 Voucher Minggu Ini',
      titleEn: 'Redeem 1 Voucher This Week',
      progress: 0,
      target: 1,
      unit: 'Voucher',
      unitEn: 'Voucher',
      rewardPoints: 100,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 7,
      period: QuestPeriod.monthly,
      title: 'Kontributor Eco-Hero 50 Kaleng',
      titleEn: 'Eco-Hero Contributor 50 Cans',
      progress: 12,
      target: 50,
      unit: 'Kaleng',
      unitEn: 'Cans',
      rewardPoints: 600,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 8,
      period: QuestPeriod.monthly,
      metric: QuestMetric.product,
      title: 'Tukar 1 Produk Kriya',
      titleEn: 'Redeem 1 Craft Product',
      progress: 0,
      target: 1,
      unit: 'Produk',
      unitEn: 'Product',
      rewardPoints: 300,
      isClaimed: false,
    ),
    const DailyQuest(
      id: 9,
      period: QuestPeriod.monthly,
      title: 'Setor 100 Kaleng Bulan Ini',
      titleEn: 'Drop 100 Cans This Month',
      progress: 12,
      target: 100,
      unit: 'Kaleng',
      unitEn: 'Cans',
      rewardPoints: 1500,
      isClaimed: false,
    ),
  ];

  static final List<UpcycleProduct> products = [
    const UpcycleProduct(
      id: 1,
      name: 'Miniatur F1',
      nameEn: 'F1 Miniature',
      description:
          'Replika mobil balap Formula 1 dari aluminium kaleng daur ulang, '
          'dirakit dan dipoles tangan.',
      descriptionEn:
          'A Formula 1 race car replica made from recycled aluminum cans, '
          'hand-assembled and hand-polished.',
      pricePoints: 15000,
      priceIdr: 150000,
      stock: 8,
    ),
    const UpcycleProduct(
      id: 2,
      name: 'Miniatur Jet Tempur',
      nameEn: 'Fighter Jet Miniature',
      description:
          'Replika jet tempur dengan detail sayap dan kokpit dari lembaran '
          'aluminium kaleng.',
      descriptionEn:
          'A fighter jet replica with detailed wings and cockpit made from '
          'aluminum can sheets.',
      pricePoints: 20000,
      priceIdr: 200000,
      stock: 5,
    ),
    const UpcycleProduct(
      id: 3,
      name: 'Miniatur Mobil Klasik',
      nameEn: 'Classic Car Miniature',
      description:
          'Replika mobil klasik berlapis anti-karat, cocok sebagai hiasan '
          'meja kerja.',
      descriptionEn:
          'A rust-proof coated classic car replica, perfect as a desk '
          'decoration.',
      pricePoints: 12000,
      priceIdr: 120000,
      stock: 10,
    ),
    const UpcycleProduct(
      id: 4,
      name: 'Miniatur Kapal Pinisi',
      nameEn: 'Pinisi Ship Miniature',
      description:
          'Replika kapal pinisi khas Nusantara dari potongan kaleng yang '
          'dibentuk satu per satu.',
      descriptionEn:
          'A replica of the traditional Nusantara pinisi ship, shaped one by '
          'one from cut aluminum cans.',
      pricePoints: 18000,
      priceIdr: 180000,
      stock: 4,
      category: ProductCategory.decor,
    ),
    const UpcycleProduct(
      id: 5,
      name: 'Vas Bunga Kaleng',
      nameEn: 'Tin Can Flower Vase',
      description:
          'Vas minimalis dari kaleng aluminium bekas, dicat tangan dan siap '
          'mempercantik sudut ruangan.',
      descriptionEn:
          'A minimalist vase from used aluminum cans, hand-painted and ready '
          'to brighten up any corner of your room.',
      pricePoints: 9000,
      priceIdr: 90000,
      stock: 12,
      category: ProductCategory.decor,
    ),
    const UpcycleProduct(
      id: 6,
      name: 'Lampu Meja Kaleng',
      nameEn: 'Tin Can Desk Lamp',
      description:
          'Lampu meja hangat dengan rangka kaleng daur ulang, cocok untuk '
          'kamar tidur dan sudut kerja.',
      descriptionEn:
          'A warm desk lamp with a recycled can frame, great for bedrooms '
          'and work corners.',
      pricePoints: 14000,
      priceIdr: 140000,
      stock: 6,
      category: ProductCategory.decor,
    ),
  ];

  static final List<Voucher> vouchers = [
    const Voucher(
      id: 1,
      titleId: 'Diskon Kuliner 20%',
      titleEn: 'Food Discount 20%',
      descriptionId: 'Berlaku di gerai makanan dan minuman mitra ReCan.',
      descriptionEn: 'Valid at ReCan partner food and beverage outlets.',
      pointsCost: 500,
      icon: AppIcons.meal,
      colors: [AppColors.gold, AppColors.goldDeep],
    ),
    const Voucher(
      id: 2,
      titleId: 'Gratis Parkir',
      titleEn: 'Free Parking',
      descriptionId: 'Gratis parkir motor satu hari di lokasi mitra.',
      descriptionEn: 'One day of free motorbike parking at partner locations.',
      pointsCost: 800,
      icon: AppIcons.parking,
      colors: [AppColors.primary, AppColors.primaryDark],
    ),
    const Voucher(
      id: 3,
      titleId: 'Diskon Fotokopi 30%',
      titleEn: 'Photocopy Discount 30%',
      descriptionId: 'Potongan biaya fotokopi dan cetak di gerai mitra.',
      descriptionEn: 'Discount on copying and printing at partner shops.',
      pointsCost: 300,
      icon: AppIcons.print,
      colors: [AppColors.primaryDark, AppColors.primaryLight],
    ),
  ];

  static final List<DropStation> dropStations = MockStations.dropStations;

  static const List<(String, double)> _rivals = [
    ('Aditya Pratama', 18.4),
    ('Salsabila Putri', 15.2),
    ('Bagas Nugroho', 11.8),
    ('Nadia Rahmawati', 9.3),
  ];

  static AvatarRef get avatar => AvatarRef(path: avatarPath, url: avatarUrl);

  static ProfileData get profile => ProfileData(
    id: _userId,
    name: currentUsername,
    email: userEmail,
    points: points,
    tier: MemberTier.of(points).name,
    phone: userPhone,
    gopayConnected: gopayConnected,
    activeVouchers: ownedVouchers.length,
    avatar: avatar,
  );

  static DashboardData get dashboard => DashboardData(
    user: UserProfile(
      id: _userId,
      name: currentUsername,
      email: userEmail,
      pointsBalance: points,
      avatar: avatar,
    ),
    dropStations: List.unmodifiable(dropStations),
    products: List.unmodifiable(products),
  );

  static GamificationData get gamification => GamificationData(
    streakDays: streakDays,
    dailyQuests: List.unmodifiable(quests),
    checkIn: DailyCheckIn(
      rewards: checkInRewards,
      todayIndex: DateTime.now().weekday - 1,
      claimedDays: Set.unmodifiable(_claimedCheckInDays),
    ),
  );

  static List<LeaderboardEntry> get leaderboard {
    final rows = [
      for (final rival in _rivals) (rival.$1, rival.$2, false),
      (currentUsername, depositedKg, true),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return [
      for (var i = 0; i < rows.length; i++)
        LeaderboardEntry(
          rank: i + 1,
          name: rows[i].$1,
          totalKg: rows[i].$2,
          isCurrentUser: rows[i].$3,
        ),
    ];
  }

  static const int _carbonStartYear = 2025;
  static const List<double> _dayFactors = [0.9, 1.1, 0.8, 1.2, 1.0, 0.7, 1.3];
  static const List<double> _weekShares = [0.22, 0.26, 0.24, 0.28];
  static int _communityMonthCans(int monthIndex) =>
      900 + 60 * monthIndex + (monthIndex % 3) * 70;

  static int get _currentMonthIndex {
    final now = DateTime.now();
    return (now.year - _carbonStartYear) * 12 + now.month - 1;
  }

  static CarbonImpact carbonImpact(CarbonRange range) {
    final points = switch (range) {
      CarbonRange.week => _weekPoints(),
      CarbonRange.month => _monthPoints(),
      CarbonRange.sinceJan2025 => _sinceJanPoints(),
    };
    return CarbonImpact(range: range, points: points);
  }

  static List<CarbonPoint> _weekPoints() {
    final today = DateTime.now().weekday - 1;
    final dailyBase = _communityMonthCans(_currentMonthIndex) / 30;
    return [
      for (var i = 6; i >= 0; i--)
        CarbonPoint.weekday(
          weekday: (today - i) % 7 + 1,
          cans:
              (dailyBase * _dayFactors[(today - i) % 7]).round() +
              (i == 0 ? userTodayCans : 0),
        ),
    ];
  }

  static List<CarbonPoint> _monthPoints() {
    final monthBase = _communityMonthCans(_currentMonthIndex);
    return [
      for (var i = 0; i < _weekShares.length; i++)
        CarbonPoint.weekOfMonth(
          week: i + 1,
          cans:
              (monthBase * _weekShares[i]).round() +
              (i == _weekShares.length - 1 ? userTotalCans : 0),
        ),
    ];
  }

  static List<CarbonPoint> _sinceJanPoints() {
    final last = _currentMonthIndex;
    return [
      for (var i = 0; i <= last; i++)
        CarbonPoint.month(
          year: _carbonStartYear + i ~/ 12,
          month: i % 12 + 1,
          cans: _communityMonthCans(i) + (i == last ? userTotalCans : 0),
        ),
    ];
  }

  static void updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    currentUsername = name;
    userEmail = email;
    userPhone = phone;
  }

  static void recordDeposit(int cans) {
    final summary = DropSessionSummary(cans: cans);
    points += summary.points;
    depositedKg += summary.grams / 1000;
    userTotalCans += cans;
    userTodayCans += cans;
    activities.insert(
      0,
      ActivityTransaction(
        transactionId: newTransactionId(),
        type: ActivityType.deposit,
        title: 'Setor $cans Kaleng',
        titleEn: 'Dropped $cans Cans',
        timestamp: DateTime.now(),
        points: summary.points,
        weightKg: summary.grams / 1000,
      ),
    );
    _advanceQuests(QuestMetric.cans, cans);
  }

  static void _advanceQuests(QuestMetric metric, int amount) {
    for (var i = 0; i < quests.length; i++) {
      final quest = quests[i];
      if (quest.isClaimed || quest.metric != metric) continue;
      quests[i] = quest.withProgress(quest.progress + amount);
    }
  }

  static void grantDemoPoints() {
    points += demoPointsGrant;
  }

  /// Back to the first-run Zero State: no points, history, owned vouchers or
  /// deposited cans. Quest progress is left alone; it never leaves zero state
  /// by itself and resetting it would need a second copy of the seed data.
  static void resetDemoState() {
    points = initialPoints;
    depositedKg = 0;
    userTotalCans = 0;
    userTodayCans = 0;
    activities.clear();
    ownedVouchers.clear();
  }

  static bool claimCheckIn() {
    final today = DateTime.now().weekday - 1;
    if (_claimedCheckInDays.contains(today)) return false;
    _claimedCheckInDays.add(today);
    points += checkInRewards[today];
    _advanceQuests(QuestMetric.checkIn, 1);
    return true;
  }

  static bool claimHelpfulBonus(int articleId, int bonusPoints) {
    if (!helpfulClaimedArticleIds.add(articleId)) return false;
    points += bonusPoints;
    return true;
  }

  static void connectGoPay() {
    gopayConnected = true;
  }

  static bool claimQuest(int questId) {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index < 0 || !quests[index].canClaim) return false;
    points += quests[index].rewardPoints;
    quests[index] = quests[index].claimed();
    return true;
  }

  static String newTransactionId() {
    final code = List.generate(
      5,
      (_) => _idAlphabet[_random.nextInt(_idAlphabet.length)],
    ).join();
    return 'REC-$code';
  }

  static ({String? failure, String? transactionId}) _spend({
    required String title,
    required String titleEn,
    required int cost,
  }) {
    if (points < cost) {
      return (
        failure: tr('Poin kamu tidak cukup.', 'You do not have enough points.'),
        transactionId: null,
      );
    }
    points -= cost;
    final transactionId = newTransactionId();
    activities.insert(
      0,
      ActivityTransaction(
        transactionId: transactionId,
        type: ActivityType.redeem,
        title: title,
        titleEn: titleEn,
        timestamp: DateTime.now(),
        points: -cost,
        weightKg: 0,
      ),
    );
    return (failure: null, transactionId: transactionId);
  }

  static ({String? failure, String? transactionId}) recordRedeem({
    required int productId,
    required int quantity,
  }) {
    final index = products.indexWhere((product) => product.id == productId);
    if (index < 0) {
      return (
        failure: tr('Produk tidak ditemukan.', 'Product not found.'),
        transactionId: null,
      );
    }
    final product = products[index];
    if (product.stock < quantity) {
      return (
        failure: tr(
          'Stok produk tidak mencukupi.',
          'Not enough product stock.',
        ),
        transactionId: null,
      );
    }
    final result = _spend(
      title: quantity > 1
          ? 'Tukar ${product.nameId} x$quantity'
          : 'Tukar ${product.nameId}',
      titleEn: quantity > 1
          ? 'Redeemed ${product.nameEn} x$quantity'
          : 'Redeemed ${product.nameEn}',
      cost: product.pricePoints * quantity,
    );
    if (result.failure != null) return result;
    products[index] = product.withStock(product.stock - quantity);
    _advanceQuests(QuestMetric.product, 1);
    return result;
  }

  static ({String? failure, String? transactionId}) recordVoucherRedeem(
    Voucher voucher,
  ) {
    final result = _spend(
      title: 'Tukar ${voucher.titleId}',
      titleEn: 'Redeemed ${voucher.titleEn}',
      cost: voucher.pointsCost,
    );
    final reference = result.transactionId;
    if (result.failure == null && reference != null) {
      ownedVouchers.insert(
        0,
        OwnedVoucher(
          voucher: voucher,
          reference: reference,
          redeemedAt: DateTime.now(),
        ),
      );
      _advanceQuests(QuestMetric.voucher, 1);
    }
    return result;
  }

  static ({String? failure, String? transactionId}) recordEWalletRedeem(
    EWalletOption option,
  ) => _spend(
    title: 'Tukar ${option.titleId}',
    titleEn: 'Redeemed ${option.titleEn}',
    cost: option.pointsCost,
  );
}
