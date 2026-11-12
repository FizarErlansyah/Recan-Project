import 'package:flutter/material.dart';

/// Eco-Green light palette. Widgets reference semantic tokens only, so a
/// palette change never requires touching feature code.
class AppColors {
  const new _();

  static const Color primary = Color(0xFF1E8E5A);
  static const Color primaryDark = Color(0xFF146B44);
  static const Color primaryDeep = Color(0xFF0D4A2F);
  static const Color primarySoft = Color(0xFFE3F5EB);
  static const Color sage = Color(0xFF1AA37A);
  static const Color sageLight = Color(0xFFBFE8D8);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F2);
  static const Color border = Color(0xFFE6E8EC);

  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6F767E);
  static const Color textTertiary = Color(0xFF9A9FA5);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const Color clay = Color(0xFFC4703F);
  static const Color clayDark = Color(0xFFA35631);
  static const Color sand = Color(0xFFD9A84E);
  static const Color sandSoft = Color(0xFFFBF1DC);

  static const Color success = Color(0xFF2E9E6B);
  static const Color successSoft = Color(0xFFE2F1E7);
  static const Color warning = Color(0xFFC98A2B);
  static const Color danger = Color(0xFFB5453B);
  static const Color dangerSoft = Color(0xFFF8E2DF);

  // Tier medals keep metallic hues because users read them as rank, not brand.
  static const Color gold = Color(0xFFE6CC86);
  static const Color goldDeep = Color(0xFFB8913F);
  static const Color silver = Color(0xFFA8B0B5);
  static const Color bronze = Color(0xFFA9703F);

  // Super-subtle edge shadows (~5-8% alpha) per the flat light aesthetic.
  static const Color shadow = Color(0x0D000000);
  static const Color shadowStrong = Color(0x1F000000);

  // Fixed near-black for surfaces that must stay dark regardless of theme
  // brightness: camera viewfinders, image scrims, always-dark chrome.
  static const Color scrim = Color(0xFF05080C);
}
