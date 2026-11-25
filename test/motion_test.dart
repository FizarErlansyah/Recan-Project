import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/widgets/count_up.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';
import 'package:mobile_apps_recan/widgets/tab_slot.dart';

import 'palette_test.dart' show contrast;

Widget _host(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

List<MainNavItem> _navItems() => [
  for (final label in ['Beranda', 'Katalog', 'Aktivitas', 'Profil'])
    MainNavItem(
      icon: hugeIcon(AppIcons.back),
      selectedIcon: hugeIcon(AppIcons.back),
      label: label,
    ),
];

void main() {
  late List<String> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('MainNavBar', () {
    Future<List<int>> pumpNav(WidgetTester tester) async {
      final taps = <int>[];
      var current = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              bottomNavigationBar: MainNavBar(
                items: _navItems(),
                currentIndex: current,
                onTap: (index) {
                  taps.add(index);
                  setState(() => current = index);
                },
              ),
            ),
          ),
        ),
      );
      return taps;
    }

    testWidgets('survives rapid retargeting and settles', (tester) async {
      final taps = await pumpNav(tester);

      await tester.tap(find.text('Katalog'));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('Profil'));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();

      expect(taps, [1, 3, 0]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fires a selection haptic only when the tab changes', (
      tester,
    ) async {
      await pumpNav(tester);

      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(haptics, isEmpty);

      await tester.tap(find.text('Aktivitas'));
      await tester.pumpAndSettle();
      expect(haptics, ['HapticFeedbackType.selectionClick']);
    });

    Finder bubble() => find.byKey(const ValueKey('nav-bubble'));
    Offset bubbleAt(WidgetTester tester) => tester.getCenter(bubble());
    double labelX(WidgetTester tester, String label) =>
        tester.getCenter(find.text(label)).dx;

    testWidgets('floats one bubble over the open tab', (tester) async {
      await pumpNav(tester);
      final surface =
          tester.getRect(find.byType(MainNavBar)).top + MainNavBar.overhang;

      expect(bubble(), findsOneWidget);
      expect(bubbleAt(tester).dx, closeTo(labelX(tester, 'Beranda'), 1));
      expect(tester.getRect(bubble()).top, lessThan(surface - 20));

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(bubbleAt(tester).dx, closeTo(labelX(tester, 'Profil'), 1));
    });

    testWidgets('hops, passes its target a little and settles', (tester) async {
      await pumpNav(tester);
      final start = bubbleAt(tester);

      await tester.tap(find.text('Aktivitas'));
      await tester.pump();
      final target = labelX(tester, 'Aktivitas');
      var furthest = start.dx;
      var highest = start.dy;
      var lowest = start.dy;
      var midway = false;
      for (var ms = 0; ms < 700; ms += 16) {
        await tester.pump(const Duration(milliseconds: 16));
        final at = bubbleAt(tester);
        if (at.dx > start.dx + 5 && at.dx < target - 5) midway = true;
        furthest = math.max(furthest, at.dx);
        highest = math.min(highest, at.dy);
        lowest = math.max(lowest, at.dy);
      }
      await tester.pumpAndSettle();

      expect(midway, isTrue);
      expect(furthest, greaterThan(target + 1));
      expect(furthest, lessThan(target + 24), reason: 'a light spring only');
      expect(highest, lessThan(start.dy - 8), reason: 'it jumps');
      expect(lowest, greaterThan(start.dy + 1), reason: 'it gives on landing');
      expect(bubbleAt(tester).dx, closeTo(target, 0.5));
      expect(bubbleAt(tester).dy, closeTo(start.dy, 0.5));
    });

    testWidgets('turns around mid-air without snapping', (tester) async {
      await pumpNav(tester);
      await tester.tap(find.text('Profil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final before = bubbleAt(tester);

      await tester.tap(find.text('Beranda'));
      await tester.pump();

      expect((bubbleAt(tester) - before).distance, lessThan(4));
      await tester.pumpAndSettle();
      expect(bubbleAt(tester).dx, closeTo(labelX(tester, 'Beranda'), 0.5));
    });

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('keeps the ${theme.brightness.name} bubble icon sharp', (
        tester,
      ) async {
        Color? icon;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              bottomNavigationBar: MainNavBar(
                items: [
                  for (final label in ['Beranda', 'Katalog'])
                    MainNavItem(
                      icon: hugeIcon(AppIcons.back),
                      selectedIcon: ({required color, required size}) {
                        icon = color;
                        return const SizedBox.square(dimension: 24);
                      },
                      label: label,
                    ),
                ],
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );
        final decoration =
            tester.widget<Container>(bubble()).decoration! as BoxDecoration;
        final surface = theme.brightness == Brightness.dark
            ? AppPalette.dark.surface
            : AppPalette.light.surface;

        expect(contrast(icon!, decoration.color!), greaterThanOrEqualTo(4.5));
        expect(contrast(decoration.color!, surface), greaterThanOrEqualTo(3));
      });
    }

    testWidgets('lets taps through the space around the bubble', (
      tester,
    ) async {
      var behind = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            extendBody: true,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => behind++,
              child: const SizedBox.expand(),
            ),
            bottomNavigationBar: MainNavBar(
              items: _navItems(),
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );
      final bar = tester.getRect(find.byType(MainNavBar));

      await tester.tapAt(Offset(bar.width * 0.62, bar.top + 8));
      expect(behind, 1);

      await tester.tapAt(bubbleAt(tester));
      expect(behind, 1, reason: 'the bubble itself is solid');
    });

    testWidgets('the open tab swaps its outline for a filled icon', (
      tester,
    ) async {
      await pumpNav(tester);
      Finder filled(int i) => find.byKey(ValueKey('nav-filled-$i'));
      Finder outline(int i) => find.byKey(ValueKey('nav-outline-$i'));

      expect(filled(0), findsOneWidget);
      expect(outline(1), findsOneWidget);

      await tester.tap(find.text('Katalog'));
      await tester.pumpAndSettle();

      expect(filled(1), findsOneWidget);
      expect(outline(0), findsOneWidget);
      expect(filled(0), findsNothing);
    });

    testWidgets('jumps under reduced motion', (tester) async {
      var current = 0;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              bottomNavigationBar: MainNavBar(
                items: _navItems(),
                currentIndex: current,
                onTap: (index) => setState(() => current = index),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Profil'));
      await tester.pump();

      expect(bubbleAt(tester).dx, closeTo(labelX(tester, 'Profil'), 1));
    });

    testWidgets('holds four equal tabs and no scan button', (tester) async {
      await pumpNav(tester);
      final bar = tester.getRect(find.byType(MainNavBar));
      final centers = [
        for (final label in ['Beranda', 'Katalog', 'Aktivitas', 'Profil'])
          labelX(tester, label),
      ];

      expect(bar.height, MainNavBar.barHeight + MainNavBar.overhang);
      for (var i = 0; i < 4; i++) {
        expect(centers[i], closeTo(bar.width / 8 * (2 * i + 1), 1));
      }
      expect(find.byKey(const ValueKey('nav-scan')), findsNothing);
    });

    testWidgets('large text does not overflow the bar', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 780);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            bottomNavigationBar: MainNavBar(
              items: _navItems(),
              currentIndex: 2,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Pressable', () {
    testWidgets('scales down while pressed and restores on release', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Pressable(
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      double scale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      expect(scale(), 1);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(), inInclusiveRange(0.96, 0.97));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), 1);
    });

    testWidgets('does not scale or vibrate when a drag starts', (tester) async {
      await tester.pumpWidget(
        _host(
          const Pressable(
            haptic: PressHaptic.light,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(haptics, isEmpty);
    });

    testWidgets('vibrates once on a clean tap', (tester) async {
      await tester.pumpWidget(
        _host(
          const Pressable(
            haptic: PressHaptic.light,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      await tester.tap(find.byType(Pressable));
      await tester.pumpAndSettle();
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('stays at full size under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(
          const Pressable(child: SizedBox(width: 100, height: 100)),
          reduceMotion: true,
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await gesture.up();
    });
  });

  group('CountUp', () {
    String fmt(double v) => v.round().toString();

    testWidgets('eases toward the target and then settles on it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(CountUp(value: 1000, format: fmt, memoryKey: 'test.ease')),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final midway = int.parse(
        tester.widget<Text>(find.byType(Text)).data ?? '0',
      );
      expect(midway, inExclusiveRange(0, 1000));

      await tester.pumpAndSettle();
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('remembers its last value across remounts', (tester) async {
      await tester.pumpWidget(
        _host(CountUp(value: 500, format: fmt, memoryKey: 'test.remember')),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(_host(const SizedBox.shrink()));
      await tester.pumpWidget(
        _host(CountUp(value: 500, format: fmt, memoryKey: 'test.remember')),
      );

      expect(find.text('500'), findsOneWidget, reason: 'no replay from zero');
    });

    testWidgets('animates from the remembered value to a new one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(CountUp(value: 100, format: fmt, memoryKey: 'test.change')),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _host(CountUp(value: 200, format: fmt, memoryKey: 'test.change')),
      );
      await tester.pump(const Duration(milliseconds: 150));
      final shown = int.parse(
        tester.widget<Text>(find.byType(Text)).data ?? '0',
      );
      expect(shown, inExclusiveRange(100, 200));
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('shows the final value immediately under reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CountUp(value: 750, format: fmt, memoryKey: 'test.reduced'),
          reduceMotion: true,
        ),
      );

      expect(find.text('750'), findsOneWidget);
    });
  });

  group('TabSlot', () {
    testWidgets('crossfades, then hides the inactive tab from the tree', (
      tester,
    ) async {
      Widget stack({required int active}) => _host(
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            children: [
              TabSlot(active: active == 0, child: const Text('first')),
              TabSlot(active: active == 1, child: const Text('second')),
            ],
          ),
        ),
      );

      await tester.pumpWidget(stack(active: 0));
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);

      await tester.pumpWidget(stack(active: 1));
      await tester.pump(const Duration(milliseconds: 80));
      expect(find.text('first'), findsOneWidget, reason: 'still fading out');
      expect(find.text('second'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('first', skipOffstage: false), findsOneWidget);
    });
  });
}
