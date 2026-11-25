import 'package:flutter/material.dart';

/// Team brand palette: Yale Blue for brand, Pearl Aqua as the soft accent,
/// Graphite and Dim Grey for text, brushed silver for structure (borders,
/// dividers, secondary icons), champagne gold reserved for points and tier
/// prestige. Widgets reference semantic tokens only, so a palette change never
/// requires touching feature code.
class AppColors {
  const new _();

  static const Color primary = Color(0xFF284B63);
  static const Color primaryDark = Color(0xFF1B3547);
  static const Color primaryDeep = Color(0xFF162B3A);
  static const Color primaryLight = Color(0xFF386282);

  // Pearl Aqua fails contrast as text on white. Use it as a fill under Yale
  // Blue or Graphite text, or as text and icons on Yale Blue and dark chrome.
  static const Color primarySoft = Color(0xFFC9EDDC);

  static const Color background = Color(0xFFF5F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F4F6);
  static const Color border = Color(0xFFD6DFE5);

  static const Color textPrimary = Color(0xFF353535);

  // The brand ships one grey. 4.5:1 holds on white, canvas and muted fills, so
  // placeholders and captions share it.
  static const Color textSecondary = Color(0xFF6A706E);
  static const Color textTertiary = textSecondary;

  // Deep forest green of the first-run surfaces: splash and sign-in header.
  static const Color forest = Color(0xFF123D31);
  static const Color forestDeep = Color(0xFF0A271F);

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

  static const Color success = Color(0xFF1B7357);
  static const Color successSoft = Color(0xFFE2F1EA);
  static const Color warning = Color(0xFFC98A2B);
  static const Color danger = Color(0xFFAD3F36);
  static const Color dangerSoft = Color(0xFFF8E2DF);

  // Reserved for overlays and sheets that genuinely need separation; cards
  // use AppDecorations borders instead.
  static const Color shadowStrong = Color(0x1F000000);

  // Fixed near-black for surfaces that must stay dark regardless of theme
  // brightness: camera viewfinders, image scrims, always-dark chrome.
  static const Color scrim = Color(0xFF05080C);
}
