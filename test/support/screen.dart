import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';

/// A phone tall enough that lazily built lists put every row in the tree.
void useTallPhone(WidgetTester tester, {double bottomInset = 0}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(411, 2000);
  tester.view.padding = FakeViewPadding(bottom: bottomInset);
  tester.view.viewPadding = FakeViewPadding(bottom: bottomInset);
  addTearDown(tester.view.reset);
}

Widget testApp(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

/// Looping animations never settle, so some screens advance by fixed frames.
Future<void> pumpFrames(WidgetTester tester, [int frames = 20]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
