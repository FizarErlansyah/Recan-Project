import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Returning user without token lands on auth landing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di ReCan'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
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
    expect(find.text('Masuk'), findsOneWidget);

    MockStore.isEnglish.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
  });
}
