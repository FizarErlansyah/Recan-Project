import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/demo/presentation/demo_tools_sheet.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/education_article.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/pages/edit_profil_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/backend/supabase_errors.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'support/recording_backend.dart';

void main() {
  tearDown(() => Backend.current = MockBackend());

  group('services use the active backend', () {
    test('a deposit passes the station and QR, then refreshes', () async {
      final backend = RecordingBackend();
      Backend.current = backend;
      final revision = DataRefresh.revision.value;

      await TransactionService.submitDrop(
        30,
        stationId: 204,
        qrCode: 'RECAN-ABC',
      );

      expect(backend.calls, ['drop:30:204:RECAN-ABC']);
      expect(DataRefresh.revision.value, revision + 1);
    });

    test('an empty deposit never reaches the backend', () async {
      final backend = RecordingBackend();
      Backend.current = backend;

      await expectLater(
        TransactionService.submitDrop(0, stationId: 204, qrCode: 'x'),
        throwsA(isA<ApiException>()),
      );

      expect(backend.calls, isEmpty);
    });

    test('a redeem returns the server reference and refreshes', () async {
      Backend.current = RecordingBackend();
      final revision = DataRefresh.revision.value;

      final receipt = await TransactionService.redeem(
        productId: 5,
        quantity: 2,
        shippingAddress: 'Jl. Mawar 1',
        pointsUsed: 18000,
      );

      expect(receipt.reference, 'REC-TEST1');
      expect(DataRefresh.revision.value, revision + 1);
    });

    test(
      'registering sends the username as name and trims the email',
      () async {
        final backend = RecordingBackend();
        Backend.current = backend;

        final signedIn = await AuthService.register(
          username: 'budi_s',
          email: '  budi@mail.com ',
          phone: '0812',
          password: 'secret1',
        );

        expect(signedIn, isTrue);
        expect(backend.calls, ['signUp:budi_s:budi_s:budi@mail.com:0812']);
      },
    );
  });

  group('demo tools', () {
    test('are available on the mock backend in debug', () {
      expect(DemoToolsSheet.isAvailable, isTrue);
    });

    test('stay off whenever real data is in use', () {
      Backend.current = RecordingBackend(remote: true);

      expect(DemoToolsSheet.isAvailable, isFalse);
    });
  });

  group('SupabaseErrors.api', () {
    ApiException map(Object error, {String? alreadyClaimed}) =>
        SupabaseErrors.api(error, alreadyClaimed: alreadyClaimed);

    test('maps RPC codes to friendly sentences', () {
      final error = map(
        const sb.PostgrestException(
          message: 'insufficient_points',
          code: 'P0001',
        ),
      );

      expect(error.message, 'Poin kamu tidak cukup.');
      expect(error.unauthorized, isFalse);
    });

    test('already_claimed uses the wording of the action', () {
      final error = map(
        const sb.PostgrestException(message: 'already_claimed', code: 'P0001'),
        alreadyClaimed: 'Hadiah hari ini sudah diklaim.',
      );

      expect(error.message, 'Hadiah hari ini sudah diklaim.');
    });

    test('every v2 server code has its own sentence', () {
      final generic = map(const sb.PostgrestException(message: 'zzz')).message;
      for (final code in [
        'invalid_qr_code',
        'invalid_points',
        'invalid_payment_method',
        'invalid_payment_channel',
        'payment_method_not_allowed',
      ]) {
        expect(
          map(sb.PostgrestException(message: code, code: '22023')).message,
          isNot(generic),
          reason: code,
        );
      }
    });

    test('an expired token asks for a new login', () {
      final error = map(
        const sb.PostgrestException(message: 'JWT expired', code: 'PGRST301'),
      );

      expect(error.unauthorized, isTrue);
    });

    test('a network failure is reported as such', () {
      expect(
        map(const SocketException('Failed host lookup')).message,
        contains('koneksi internet'),
      );
    });

    test('an unknown failure never leaks its raw text', () {
      expect(
        map(const sb.PostgrestException(message: 'relation "x" does not exist'))
            .message,
        isNot(contains('relation')),
      );
    });
  });

  group('SupabaseErrors.auth', () {
    String message(Object error) => SupabaseErrors.auth(error).message;

    test('wrong credentials', () {
      expect(
        message(
          const sb.AuthApiException(
            'Invalid login credentials',
            statusCode: '400',
            code: 'invalid_credentials',
          ),
        ),
        'Email atau kata sandi salah.',
      );
    });

    test('email already registered', () {
      expect(
        message(
          const sb.AuthApiException(
            'User already registered',
            statusCode: '422',
            code: 'user_already_exists',
          ),
        ),
        'Email ini sudah terdaftar. Silakan masuk.',
      );
    });

    test('weak password', () {
      expect(
        message(
          const sb.AuthApiException(
            'Password should be at least 6 characters.',
            statusCode: '422',
            code: 'weak_password',
          ),
        ),
        'Kata sandi minimal 6 karakter.',
      );
    });

    test('unconfirmed email', () {
      expect(
        message(
          const sb.AuthApiException(
            'Email not confirmed',
            statusCode: '400',
            code: 'email_not_confirmed',
          ),
        ),
        'Email belum diverifikasi. Cek kotak masukmu.',
      );
    });

    test('rate limiting', () {
      expect(
        message(
          const sb.AuthApiException(
            'email rate limit exceeded',
            statusCode: '429',
            code: 'over_email_send_rate_limit',
          ),
        ),
        contains('Terlalu banyak percobaan'),
      );
    });

    test('offline', () {
      expect(
        message(sb.AuthRetryableFetchException()),
        contains('koneksi internet'),
      );
    });
  });

  group('rows from Supabase become app models', () {
    test('profile and user rows read points, tier, cans and avatar', () {
      final row = {
        'id': 'u-1',
        'full_name': 'Budi Santoso',
        'email': 'budi@mail.com',
        'points': 1250,
        'total_cans': 50,
        'tier': 'Silver',
        'phone': '0812',
        'gopay_connected': true,
        'avatar_url': 'https://x.supabase.co/a.jpg?t=1',
      };

      final profile = ProfileData.fromJson({...row, 'active_vouchers': 2});
      final user = UserProfile.fromJson(row);

      expect(profile.points, 1250);
      expect(profile.tier, 'Silver');
      expect(profile.activeVouchers, 2);
      expect(profile.gopayConnected, isTrue);
      expect(profile.avatar.url, 'https://x.supabase.co/a.jpg?t=1');
      expect(profile.initials, 'BS');
      expect(user.totalCans, 50);
      expect(user.pointsBalance, 1250);
    });

    test('a station row carries both languages, distance and position', () {
      final row = {
        'id': 204,
        'name': 'Drop Station Stasiun Jurang Mangu',
        'name_en': 'Drop Station at Jurang Mangu Station',
        'location': 'Stasiun KRL Jurang Mangu',
        'location_en': 'Jurang Mangu KRL Station',
        'capacity_percentage': 48,
        'status': 'available',
        'distance_m': 66,
        'lat': -6.28858,
        'lng': 106.72915,
        'image_url': null,
      };

      final station = DropStation.fromJson(row);
      final pin = MapStation.fromJson(row);

      expect(station.distanceLabel, '66 m');
      expect(station.position?.latitude, -6.28858);
      expect(station.nameEn, 'Drop Station at Jurang Mangu Station');
      expect(pin.capacityPercent, 48);
      expect(pin.position.longitude, 106.72915);
    });

    test('a voucher row picks its icon and gradient', () {
      final voucher = Voucher.fromJson({
        'id': 101,
        'name': 'Diskon Kuliner 20%',
        'name_en': 'Food Discount 20%',
        'description': 'd',
        'description_en': 'd',
        'price_points': 500,
        'icon_key': 'meal',
        'gradient_hex': ['#C8A252', '#8A6D28'],
      });

      expect(voucher.pointsCost, 500);
      expect(voucher.colors.first, const Color(0xFFC8A252));
      expect(voucher.colors.last, const Color(0xFF8A6D28));
    });

    test('a voucher without a style still gets a gradient', () {
      final voucher = Voucher.fromJson({
        'id': 102,
        'name': 'n',
        'name_en': 'n',
        'description': 'd',
        'description_en': 'd',
        'price_points': 1,
      });

      expect(voucher.colors, hasLength(2));
    });

    test('a transaction row maps quest rewards as income', () {
      final transaction = ActivityTransaction.fromJson({
        'reference': 'REC-AB123',
        'type': 'quest',
        'title': 'Hadiah Misi: Setor 5 Kaleng Hari Ini',
        'title_en': 'Quest Reward: Drop 5 Cans Today',
        'created_at': '2026-11-24T03:00:00+00:00',
        'points_delta': 50,
        'weight_kg': 0,
      });

      expect(transaction.type, ActivityType.quest);
      expect(transaction.isIncome, isTrue);
      expect(transaction.transactionId, 'REC-AB123');
    });

    test('a quest row reads both languages and progress', () {
      final quest = DailyQuest.fromJson({
        'id': 1,
        'title': 'Setor 5 Kaleng Hari Ini',
        'title_en': 'Drop 5 Cans Today',
        'unit': 'Kaleng',
        'unit_en': 'Cans',
        'period': 'daily',
        'metric': 'checkIn',
        'target': 5,
        'reward_points': 50,
        'progress': 5,
        'is_claimed': false,
      });

      expect(quest.metric, QuestMetric.checkIn);
      expect(quest.canClaim, isTrue);
    });

    test('a leaderboard row uses the full name', () {
      final entry = LeaderboardEntry.fromJson({
        'rank': 2,
        'full_name': 'Sari Putri',
        'total_kg': 5.9,
        'is_current_user': true,
      });

      expect(entry.name, 'Sari Putri');
      expect(entry.totalKg, 5.9);
      expect(entry.isCurrentUser, isTrue);
    });

    test('an article row keeps paragraphs, stats and category', () {
      final article = EducationArticle.fromJson({
        'id': 1,
        'category': 'impact',
        'title': 't',
        'title_en': 'te',
        'summary': 's',
        'summary_en': 'se',
        'paragraphs': ['a', 'b'],
        'paragraphs_en': ['c', 'd'],
        'insight': 'i',
        'insight_en': 'ie',
        'stats': [
          {'value': '8', 'label': 'Titik', 'label_en': 'Points'},
        ],
        'read_minutes': 4,
        'published_at': '2026-10-12T00:00:00+07:00',
      });

      expect(article.category, EducationCategory.impact);
      expect(article.paragraphsId, ['a', 'b']);
      expect(article.stats.single.value, '8');
    });

    test('carbon summary rows become chart bars for every range', () {
      final week = CarbonImpact.fromSummary(CarbonRange.week, [
        {'cans': 100, 'bucket_index': 1, 'bucket_start': '2026-11-23'},
      ]);
      final month = CarbonImpact.fromSummary(CarbonRange.month, [
        {'cans': 400, 'bucket_index': 3, 'bucket_start': '2026-11-15'},
      ]);
      final since = CarbonImpact.fromSummary(CarbonRange.sinceJan2025, [
        {'cans': 900, 'bucket_index': 1, 'bucket_start': '2025-01-01'},
      ]);

      expect(week.points.single.labelId, 'Sen');
      expect(month.points.single.labelEn, 'W3');
      expect(since.points.single.labelId, 'Jan 25');
      expect(week.totalCans, 100);
    });
  });

  group('auth screens', () {
    Future<void> openRegister(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      await tester.pumpWidget(const ReCanApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('auth-tab-register')));
      await tester.pumpAndSettle();
    }

    testWidgets('a short password is rejected before any request', (
      tester,
    ) async {
      final backend = RecordingBackend();
      Backend.current = backend;
      await openRegister(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'budi_s');
      await tester.enterText(fields.at(1), 'budi@mail.com');
      await tester.enterText(fields.at(2), '0812');
      await tester.enterText(fields.at(3), '12345');
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
      expect(backend.calls, isEmpty);
    });

    testWidgets('an account that needs email confirmation lands on login', (
      tester,
    ) async {
      final backend = RecordingBackend(signUpSignsIn: false);
      Backend.current = backend;
      await openRegister(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'budi_s');
      await tester.enterText(fields.at(1), 'budi@mail.com');
      await tester.enterText(fields.at(2), '0812');
      await tester.enterText(fields.at(3), 'secret1');
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();

      expect(backend.calls, hasLength(1));
      expect(find.textContaining('Cek emailmu'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('auth-submit')),
          matching: find.text('Masuk'),
        ),
        findsOneWidget,
      );
      final emailField = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(emailField.controller?.text, 'budi@mail.com');
    });
  });

  group('Edit Profil', () {
    Future<TextFormField> emailFieldWith(
      WidgetTester tester, {
      required bool editable,
    }) async {
      Backend.current = RecordingBackend(editableEmail: editable);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const EditProfilPage(
            profile: ProfileData(
              id: 'u-1',
              name: 'Budi Santoso',
              email: 'budi@mail.com',
              points: 0,
              tier: 'Bronze',
              phone: '0812',
              gopayConnected: false,
              activeVouchers: 0,
            ),
          ),
        ),
      );
      return tester.widget<TextFormField>(find.byType(TextFormField).at(1));
    }

    testWidgets('the email is read-only when the account cannot change it', (
      tester,
    ) async {
      final field = await emailFieldWith(tester, editable: false);

      expect(field.enabled, isFalse);
    });

    testWidgets('the email stays editable on the mock backend', (tester) async {
      final field = await emailFieldWith(tester, editable: true);

      expect(field.enabled, isTrue);
    });
  });
}
