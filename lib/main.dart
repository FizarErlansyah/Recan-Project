import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/core/theme/language_extension.dart';
import 'package:mobile_apps_recan/pages/splash_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/theme_preference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await ThemePreference.load();
  await ProfileService.restoreAvatar();
  runApp(const ReCanApp());
}

class ReCanApp extends StatelessWidget {
  const new({super.key});

  // copyWith replaces the extension list, so the palette registered by the
  // base theme has to be carried over next to the language extension.
  static ThemeData _localized(ThemeData base, {required bool isEnglish}) {
    return base.copyWith(
      extensions: [
        ...base.extensions.values,
        LanguageExtension(isEnglish: isEnglish),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemePreference.mode,
      builder: (context, themeMode, _) => ValueListenableBuilder<bool>(
        valueListenable: MockStore.isEnglish,
        builder: (context, isEnglish, _) => MaterialApp(
          title: 'ReCan',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: _localized(AppTheme.light, isEnglish: isEnglish),
          darkTheme: _localized(AppTheme.dark, isEnglish: isEnglish),
          home: const SplashPage(),
        ),
      ),
    );
  }
}
