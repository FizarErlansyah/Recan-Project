import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/leaderboard_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/payment_methods_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/tier_and_voucher_section.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/widgets/account_header.dart';
import 'package:mobile_apps_recan/widgets/leaderboard_tile.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';

import 'support/screen.dart';

const _email = 'recan.pengguna.dengan.alamat.panjang.2511@contoh.example.com';

LeaderboardEntry _entry(int rank, String name, {bool you = false}) =>
    LeaderboardEntry(
      rank: rank,
      name: name,
      totalKg: (10 - rank).toDouble(),
      isCurrentUser: you,
    );

Widget _page(Widget child, {double scale = 1, bool still = false}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: still,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    ),
  ),
);

void _narrow(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 1600);
  addTearDown(tester.view.reset);
}

void main() {
  group('payment methods', () {
    Future<void> show(
      WidgetTester tester, {
      required bool connected,
      double scale = 1,
    }) async {
      _narrow(tester);
      await tester.pumpWidget(
        _page(
          PaymentMethodsSection(
            points: 114,
            gopayConnected: connected,
            onConnectGoPay: () async {},
          ),
          scale: scale,
        ),
      );
    }

    testWidgets('cards wrap their content instead of padding it out', (
      tester,
    ) async {
      await show(tester, connected: true);

      expect(
        tester.getSize(find.byType(Card).first).height,
        lessThanOrEqualTo(116),
      );
      expect(
        tester.getSize(find.byType(Card).first).height,
        tester.getSize(find.byType(Card).last).height,
      );
    });

    testWidgets('a connected wallet reads tick then status on one line', (
      tester,
    ) async {
      await show(tester, connected: true);
      final tick = find.byKey(const ValueKey('gopay-tick'));
      final label = find.text('Terhubung');

      expect(tester.getCenter(tick).dy, closeTo(tester.getCenter(label).dy, 1));
      expect(
        tester.getTopRight(tick).dx,
        lessThan(tester.getTopLeft(label).dx),
      );
      expect(tester.widget<Text>(label).style?.color, AppPalette.light.success);
    });

    testWidgets('grows with large text instead of clipping', (tester) async {
      await show(tester, connected: false, scale: 2);

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a long email is shown in full', (tester) async {
    _narrow(tester);
    await tester.pumpWidget(
      _page(
        const AccountHeader(
          profile: ProfileData(
            id: 'u',
            name: 'Budi Santoso Wijaya Kusuma',
            email: _email,
            points: 100,
            tier: 'Bronze',
            phone: '081200000000',
            gopayConnected: false,
            activeVouchers: 0,
          ),
        ),
      ),
    );

    final email = tester.widget<Text>(find.text(_email));
    expect(email.maxLines, isNull);
    expect(email.overflow, isNull);
    expect(tester.getSize(find.text(_email)).width, greaterThan(200));
    expect(tester.takeException(), isNull);
  });

  test('a leaderboard row reads the avatar', () {
    final entry = LeaderboardEntry.fromJson({
      'rank': 1,
      'full_name': 'Ayu',
      'total_kg': 2,
      'avatar_url': 'https://example.test/a.jpg',
      'is_current_user': false,
    });

    expect(entry.avatar.url, 'https://example.test/a.jpg');
  });

  group('leaderboard', () {
    final five = [
      _entry(1, 'Ayu'),
      _entry(2, 'Bima'),
      _entry(3, 'Citra'),
      _entry(4, 'Dimas'),
      _entry(5, 'Eka', you: true),
    ];
    Finder step(int rank) => find.byKey(ValueKey('podium-$rank'));

    testWidgets('puts the top three on a podium, first in the middle', (
      tester,
    ) async {
      await tester.pumpWidget(_page(LeaderboardSection(entries: five)));
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(step(2)).dx,
        lessThan(tester.getCenter(step(1)).dx),
      );
      expect(
        tester.getCenter(step(1)).dx,
        lessThan(tester.getCenter(step(3)).dx),
      );
      expect(
        tester.getSize(step(1)).height,
        greaterThan(tester.getSize(step(2)).height),
      );
      expect(
        tester.getSize(step(2)).height,
        greaterThan(tester.getSize(step(3)).height),
      );
      expect(find.byType(LeaderboardTile), findsNWidgets(2));
      expect(find.byType(ProfileAvatar), findsNWidgets(5));
      expect(find.text('Eka (Kamu)'), findsOneWidget);
    });

    testWidgets('the steps rise into place', (tester) async {
      await tester.pumpWidget(_page(LeaderboardSection(entries: five)));
      await tester.pump(const Duration(milliseconds: 100));
      final early = tester.getSize(step(1)).height;
      await tester.pumpAndSettle();

      expect(early, lessThan(tester.getSize(step(1)).height));
    });

    testWidgets('stands still under reduced motion', (tester) async {
      await tester.pumpWidget(
        _page(LeaderboardSection(entries: five), still: true),
      );
      final first = tester.getSize(step(1)).height;
      await tester.pumpAndSettle();

      expect(tester.getSize(step(1)).height, first);
    });

    testWidgets('copes with a single contributor', (tester) async {
      await tester.pumpWidget(
        _page(LeaderboardSection(entries: [_entry(1, 'Ayu', you: true)])),
      );
      await tester.pumpAndSettle();

      expect(step(1), findsOneWidget);
      expect(step(2), findsNothing);
      expect(find.text('Ayu (Kamu)'), findsOneWidget);
    });

    testWidgets('says so when nobody has deposited', (tester) async {
      await tester.pumpWidget(_page(const LeaderboardSection(entries: [])));

      expect(find.text('Belum ada kontributor.'), findsOneWidget);
    });

    testWidgets('fits large text on a narrow phone', (tester) async {
      _narrow(tester);
      await tester.pumpWidget(
        _page(LeaderboardSection(entries: five), scale: 1.6),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('tier card', () {
    Future<void> show(
      WidgetTester tester,
      int points, {
      double scale = 1,
    }) async {
      _narrow(tester);
      await tester.pumpWidget(
        _page(
          TierAndVoucherSection(
            points: points,
            activeVouchers: 2,
            onTierTap: () {},
            onVoucherTap: () {},
          ),
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows how far the next tier is', (tester) async {
      await show(tester, 400);

      expect(find.text('600 poin lagi ke Silver'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('keeps the medal clear of the tier name', (tester) async {
      await show(tester, 400);
      final medal = find.byKey(const ValueKey('tier-medal'));

      expect(
        tester.getTopLeft(find.text('Bronze')).dy -
            tester.getBottomLeft(medal).dy,
        greaterThanOrEqualTo(8),
      );
    });

    testWidgets('says when there is no higher tier', (tester) async {
      await show(tester, 9000);

      expect(find.text('Tier tertinggi'), findsOneWidget);
    });

    testWidgets('fits large text', (tester) async {
      await show(tester, 400, scale: 1.6);

      expect(tester.takeException(), isNull);
    });
  });
}
