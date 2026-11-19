import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/widgets/count_up.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';
import 'package:mobile_apps_recan/widgets/tab_slot.dart';

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

    testWidgets('arcs upward mid-hop without leaving the bar bounds', (
      tester,
    ) async {
      await pumpNav(tester);
      final bubble = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == MainNavBar.bubbleSize &&
            w.constraints?.maxHeight == MainNavBar.bubbleSize,
      );
      final barTop = tester.getRect(find.byType(MainNavBar)).top;
      final restTop = tester.getRect(bubble).top;

      await tester.tap(find.text('Katalog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final apexTop = tester.getRect(bubble).top;

      expect(restTop - apexTop, closeTo(MainNavBar.lift, 0.5));
      expect(apexTop, greaterThanOrEqualTo(barTop));

      await tester.pumpAndSettle();
      expect(tester.getRect(bubble).top, closeTo(restTop, 0.01));
    });

    testWidgets('keeps the hop headroom inside its own bounds', (tester) async {
      await pumpNav(tester);

      final bar = tester.getRect(find.byType(MainNavBar));
      expect(
        bar.height,
        MainNavBar.barHeight + MainNavBar.overhang,
        reason: 'overhang must include the hop headroom',
      );
      expect(MainNavBar.lift, inInclusiveRange(10, 14));
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
