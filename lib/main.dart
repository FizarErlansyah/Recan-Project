import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/core/theme/language_extension.dart';
import 'package:mobile_apps_recan/pages/splash_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const ReCanApp());
}

class ReCanApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MockStore.isEnglish,
      builder: (context, isEnglish, _) => MaterialApp(
        title: 'ReCan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme.copyWith(
          extensions: [LanguageExtension(isEnglish: isEnglish)],
        ),
        home: const SplashPage(),
      ),
    );
  }
}
