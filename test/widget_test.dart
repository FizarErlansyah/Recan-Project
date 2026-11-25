import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Returning user without token lands on auth landing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di ReCan'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-tab-login')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-tab-register')), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    // The tab and the submit button both say it.
    expect(find.text('Masuk'), findsNWidgets(2));
  });

  testWidgets('First launch lands on onboarding page', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Daur Ulang', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Lanjut'), findsOneWidget);
  });

  testWidgets('Switching language rebuilds the pushed login page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    addTearDown(() => MockStore.isEnglish.value = false);

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsNWidgets(2));

    MockStore.isEnglish.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsNWidgets(2));
    expect(find.text('Masuk'), findsNothing);
  });
}
