import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User choice between following the system, light or dark. Defaults to the
/// system so a phone already in dark mode gets a dark app on first launch.
abstract final class ThemePreference {
  static const String _key = 'theme_mode';

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    mode.value = ThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> select(ThemeMode value) async {
    mode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
