import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/avatar_source_sheet.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/services/avatar_store.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/initials.dart';
import 'package:mobile_apps_recan/widgets/home_hero_header.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1x1 transparent PNG, enough for the decoder to accept as an image file.
final List<int> _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  late Directory sandbox;
  late File source;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sandbox = await Directory.systemTemp.createTemp('recan_avatar_');
    AvatarStore.documentsDirectory = () async => sandbox;
    source = await File('${sandbox.path}/picked.png').writeAsBytes(_png);
  });

  tearDown(() async {
    MockStore.avatarPath = null;
    MockStore.avatarUrl = null;
    await sandbox.delete(recursive: true);
  });

  group('initialsOf', () {
    test('takes the first letter of up to two words', () {
      expect(initialsOf('Guest'), 'G');
      expect(initialsOf('  budi   santoso wijaya '), 'BS');
    });

    test('is empty for a blank name instead of throwing', () {
      expect(initialsOf('   '), '');
    });
  });

  group('AvatarStore', () {
    test('copies the picked file into app storage and remembers it', () async {
      final saved = await AvatarStore.save(source.path);

      expect(saved, isNot(source.path));
      expect(saved, endsWith('.png'));
      expect(File(saved).readAsBytesSync(), _png);
      expect(await AvatarStore.load(), saved);
    });

    test('replacing the photo removes the previous copy', () async {
      final first = await AvatarStore.save(source.path);
      final second = await AvatarStore.save(source.path);

      expect(second, isNot(first));
      expect(File(first).existsSync(), isFalse);
      expect(File(second).existsSync(), isTrue);
    });

    test('clear deletes the file and forgets the path', () async {
      final saved = await AvatarStore.save(source.path);

      await AvatarStore.clear();

      expect(File(saved).existsSync(), isFalse);
      expect(await AvatarStore.load(), isNull);
    });

    test('load forgets a path whose file is gone', () async {
      final saved = await AvatarStore.save(source.path);
      File(saved).deleteSync();

      expect(await AvatarStore.load(), isNull);
      expect(await AvatarStore.load(), isNull);
    });
  });

  group('ProfileService avatar', () {
    test(
      'update stores the photo, exposes it and refreshes listeners',
      () async {
        final revision = DataRefresh.revision.value;

        final avatar = await ProfileService.updateAvatar(source.path);

        expect(avatar.path, isNotNull);
        expect(File(avatar.path!).existsSync(), isTrue);
        expect((await ProfileService.fetchProfile()).avatar.path, avatar.path);
        expect(MockStore.dashboard.user.avatar.path, avatar.path);
        expect(DataRefresh.revision.value, revision + 1);
      },
    );

    test('remove clears the photo everywhere', () async {
      await ProfileService.updateAvatar(source.path);

      final avatar = await ProfileService.removeAvatar();

      expect(avatar.isEmpty, isTrue);
      expect((await ProfileService.fetchProfile()).avatar.isEmpty, isTrue);
    });

    test('restore brings the saved photo back after a restart', () async {
      final saved = await AvatarStore.save(source.path);
      MockStore.avatarPath = null;

      await ProfileService.restoreAvatar();

      expect(MockStore.avatarPath, saved);
    });
  });

  group('ProfileAvatar', () {
    Future<void> pumpAvatar(WidgetTester tester, AvatarRef avatar) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: ProfileAvatar(initials: 'GU', avatar: avatar, size: 42),
            ),
          ),
        ),
      );
    }

    testWidgets('shows initials when there is no photo', (tester) async {
      await pumpAvatar(tester, AvatarRef.none);

      expect(find.text('GU'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows the photo instead of the initials', (tester) async {
      await pumpAvatar(tester, AvatarRef(path: source.path));

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('GU'), findsNothing);
    });
  });

  group('HomeHeroHeader avatar', () {
    Future<void> pumpHeader(WidgetTester tester, VoidCallback onOpenProfile) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ListView(
              children: [
                HomeHeroHeader(
                  user: const UserProfile(
                    id: 1,
                    name: 'Budi Santoso',
                    email: 'budi@recan.id',
                    pointsBalance: 0,
                  ),
                  cansDeposited: 0,
                  onAskAi: () {},
                  onScan: () {},
                  onOpenProfile: onOpenProfile,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('shows the initials and opens the profile on tap', (
      tester,
    ) async {
      var opened = 0;
      await pumpHeader(tester, () => opened++);

      expect(find.text('BS'), findsOneWidget);
      await tester.tap(find.text('BS'));

      expect(opened, 1);
    });
  });

  group('AvatarSourceSheet', () {
    Future<void> openSheet(
      WidgetTester tester, {
      required bool hasPhoto,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    AvatarSourceSheet.show(context, hasPhoto: hasPhoto),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('offers camera and gallery without a photo', (tester) async {
      await openSheet(tester, hasPhoto: false);

      expect(find.text('Ambil dari Kamera'), findsOneWidget);
      expect(find.text('Pilih dari Galeri'), findsOneWidget);
      expect(find.text('Hapus Foto'), findsNothing);
    });

    testWidgets('adds remove once a photo exists', (tester) async {
      await openSheet(tester, hasPhoto: true);

      expect(find.text('Hapus Foto'), findsOneWidget);
    });
  });
}
