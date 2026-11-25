import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/motion/shake.dart';
import 'package:mobile_apps_recan/widgets/motion/shimmer.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';

Widget _host(Widget child, {bool still = false}) => MaterialApp(
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: still),
    child: app!,
  ),
  home: Scaffold(body: Center(child: child)),
);

double _opacityOver(WidgetTester tester, String text) => tester
    .widget<FadeTransition>(
      find
          .ancestor(of: find.text(text), matching: find.byType(FadeTransition))
          .first,
    )
    .opacity
    .value;

void main() {
  group('BouncyTap', () {
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
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    double scale(WidgetTester tester) =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    Future<TestGesture> press(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('go')),
      );
      await tester.pump();
      return gesture;
    }

    testWidgets('shrinks to 0.96 in 120ms, taps once and may vibrate', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          BouncyTap(haptic: true, onTap: () => taps++, child: const Text('go')),
        ),
      );

      final gesture = await press(tester);
      expect(scale(tester), 0.96);
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
        const Duration(milliseconds: 120),
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(scale(tester), 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('is silent unless haptic is asked for', (tester) async {
      await tester.pumpWidget(
        _host(BouncyTap(onTap: () {}, child: const Text('go'))),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(haptics, isEmpty);
    });

    testWidgets('keeps full size under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(BouncyTap(onTap: () {}, child: const Text('go')), still: true),
      );

      final gesture = await press(tester);
      expect(scale(tester), 1);
      await gesture.up();
    });
  });

  group('StaggeredEntrance', () {
    const list = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StaggeredEntrance(child: Text('first')),
        StaggeredEntrance(index: 3, child: Text('fourth')),
      ],
    );

    testWidgets('later items wait their turn, then all settle', (tester) async {
      await tester.pumpWidget(_host(list));
      final start = tester.getTopLeft(find.text('first')).dy;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(_opacityOver(tester, 'first'), greaterThan(0));
      expect(_opacityOver(tester, 'fourth'), 0);

      await tester.pumpAndSettle();
      expect(_opacityOver(tester, 'fourth'), 1);
      final travelled = start - tester.getTopLeft(find.text('first')).dy;
      expect(travelled, inInclusiveRange(16, 24));
    });

    testWidgets('shows at once under reduced motion', (tester) async {
      await tester.pumpWidget(_host(list, still: true));

      expect(_opacityOver(tester, 'fourth'), 1);
      expect(await tester.pumpAndSettle(), 1, reason: 'nothing left to move');
    });

    testWidgets('an explicit delay wins over the index', (tester) async {
      await tester.pumpWidget(
        _host(
          const StaggeredEntrance(
            delay: Duration(milliseconds: 500),
            child: Text('late'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(_opacityOver(tester, 'late'), 0);
      await tester.pumpAndSettle();
    });
  });

  group('AnimatedCountUp', () {
    String shown(WidgetTester tester) =>
        tester.widget<Text>(find.byType(Text)).data!;

    testWidgets('climbs to the value with Indonesian thousands', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AnimatedCountUp(value: 12500, prefix: '+', suffix: ' Poin'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(shown(tester), isNot('+12.500 Poin'));

      await tester.pumpAndSettle();
      expect(shown(tester), '+12.500 Poin');
    });

    testWidgets('moves on from where it was when the value changes', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const AnimatedCountUp(value: 1000)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host(const AnimatedCountUp(value: 2000)));
      await tester.pump(const Duration(milliseconds: 100));

      final midway = int.parse(shown(tester).replaceAll('.', ''));
      expect(midway, inExclusiveRange(1000, 2000));
      await tester.pumpAndSettle();
    });

    test('a negative number keeps its sign in front', () {
      expect(AnimatedCountUp.format(-100), '-100');
      expect(AnimatedCountUp.format(-1500), '-1.500');
      expect(AnimatedCountUp.format(0), '0');
    });

    testWidgets('is final at once under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(const AnimatedCountUp(value: 900), still: true),
      );

      expect(shown(tester), '900');
    });
  });

  group('ShimmerBox', () {
    testWidgets('animates on its own', (tester) async {
      await tester.pumpWidget(_host(const ShimmerBox(width: 80)));

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('holds still under reduced motion', (tester) async {
      await tester.pumpWidget(_host(const ShimmerBox(width: 80), still: true));

      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('shares one sweep inside a Shimmer', (tester) async {
      await tester.pumpWidget(
        _host(
          const Shimmer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ShimmerBox(width: 80), ShimmerBox(width: 60)],
            ),
          ),
          still: true,
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('RecanPageRoute', () {
    Future<void> push(WidgetTester tester, {required bool still}) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                RecanPageRoute<void>(
                  page: const Scaffold(body: Text('next')),
                  axis: Axis.horizontal,
                ),
              ),
              child: const Text('go'),
            ),
          ),
          still: still,
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
    }

    testWidgets('slides in along its axis', (tester) async {
      await push(tester, still: false);
      final early = tester.getTopLeft(find.text('next'));
      await tester.pumpAndSettle();
      final done = tester.getTopLeft(find.text('next'));

      expect(early.dx, greaterThan(done.dx));
      expect(early.dy, done.dy);
    });

    testWidgets('only fades under reduced motion', (tester) async {
      await push(tester, still: true);
      final early = tester.getTopLeft(find.text('next'));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('next')), early);
    });
  });

  group('Shake', () {
    Future<double> shiftAfterSignal(
      WidgetTester tester, {
      required bool still,
    }) async {
      await tester.pumpWidget(
        _host(const Shake(signal: 0, child: Text('form')), still: still),
      );
      final rest = tester.getTopLeft(find.text('form')).dx;
      await tester.pumpWidget(
        _host(const Shake(signal: 1, child: Text('form')), still: still),
      );
      await tester.pump(const Duration(milliseconds: 40));
      final shift = (tester.getTopLeft(find.text('form')).dx - rest).abs();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('form')).dx, rest);
      return shift;
    }

    testWidgets('nudges sideways when the signal changes', (tester) async {
      expect(await shiftAfterSignal(tester, still: false), greaterThan(0));
    });

    testWidgets('stays put under reduced motion', (tester) async {
      expect(await shiftAfterSignal(tester, still: true), 0);
    });
  });
}
