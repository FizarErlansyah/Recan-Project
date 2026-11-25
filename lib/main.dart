import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_apps_recan/core/config/supabase_config.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/core/theme/language_extension.dart';
import 'package:mobile_apps_recan/pages/splash_page.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/supabase_backend.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/theme_preference.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await ThemePreference.load();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  Backend.current = SupabaseBackend(Supabase.instance.client);
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
          // Keeps the framework's own words (back button, dialog scrim, text
          // menu) in the language chosen inside the app.
          locale: Locale(isEnglish ? 'en' : 'id'),
          supportedLocales: const [Locale('id'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: themeMode,
          theme: _localized(AppTheme.light, isEnglish: isEnglish),
          darkTheme: _localized(AppTheme.dark, isEnglish: isEnglish),
          home: const SplashPage(),
        ),
      ),
    );
  }
}
