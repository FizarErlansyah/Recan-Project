import 'package:flutter/material.dart';

/// Eco-Metallic palette: deep emerald for brand, brushed silver for structure
/// (borders, dividers, secondary icons), champagne gold reserved for points
/// and tier prestige. Widgets reference semantic tokens only, so a palette
/// change never requires touching feature code.
class AppColors {
  const new _();

  static const Color primary = Color(0xFF0D5C46);
  static const Color primaryDark = Color(0xFF083D2E);
  static const Color primaryDeep = Color(0xFF052B20);
  static const Color primarySoft = Color(0xFFE4F0EB);
  static const Color sage = Color(0xFF2F8570);
  static const Color sageLight = Color(0xFFA9DCCD);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F5);
  static const Color border = Color(0xFFD8DEE4);

  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF5F6B78);
  static const Color textTertiary = Color(0xFF64707C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Brushed-aluminium pair: light for hairlines on dark surfaces, mid for
  // secondary icons and rank accents.
  static const Color silverLight = Color(0xFFCBD5E1);
  static const Color silver = Color(0xFF94A3B8);
  static const Color slate = Color(0xFF475569);
  static const Color slateDeep = Color(0xFF334155);

  // Champagne gold is exclusive to points, tier and mission highlights.
  // `goldDeep` is the only gold dark enough for text on light surfaces.
  static const Color gold = Color(0xFFC8A252);
  static const Color goldDeep = Color(0xFF8A6D28);
  static const Color goldLight = Color(0xFFE4CD94);
  static const Color goldSoft = Color(0xFFF6EEDB);

  static const Color bronze = Color(0xFFA9703F);
  static const Color bronzeLight = Color(0xFFDDA877);

  static const Color clay = Color(0xFFC4703F);
  static const Color sand = Color(0xFFD9A84E);
  static const Color sandSoft = Color(0xFFFBF1DC);

  static const Color success = Color(0xFF1F7A5C);
  static const Color successSoft = Color(0xFFE2F1EA);
  static const Color warning = Color(0xFFC98A2B);
  static const Color danger = Color(0xFFB5453B);
  static const Color dangerSoft = Color(0xFFF8E2DF);

  // Reserved for overlays and sheets that genuinely need separation; cards
  // use AppDecorations borders instead.
  static const Color shadowStrong = Color(0x1F000000);

  // Fixed near-black for surfaces that must stay dark regardless of theme
  // brightness: camera viewfinders, image scrims, always-dark chrome.
  static const Color scrim = Color(0xFF05080C);
}
