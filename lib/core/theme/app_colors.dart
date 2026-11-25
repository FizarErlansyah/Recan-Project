import 'package:flutter/material.dart';

/// Team brand palette: Yale Blue for brand, Pearl Aqua as the soft accent,
/// warm amber for points and streaks, champagne gold for tier prestige, brushed
/// silver for details on dark chrome. Widgets reference semantic tokens only,
/// so a palette change never requires touching feature code.
class AppColors {
  const new _();

  static const Color primary = Color(0xFF284B63);
  static const Color primaryDark = Color(0xFF1B3547);
  static const Color primaryDeep = Color(0xFF162B3A);
  static const Color primaryLight = Color(0xFF386282);

  // Pearl Aqua fails contrast as text on white. Use it as a fill under Yale
  // Blue or Graphite text, or as text and icons on Yale Blue and dark chrome.
  static const Color primarySoft = Color(0xFFC9EDDC);

  static const Color background = Color(0xFFEEF3F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE8EEF2);
  static const Color border = Color(0xFFD5E0E7);

  static const Color textPrimary = Color(0xFF14232E);

  // 4.5:1 holds on white, canvas, muted and tinted fills, so placeholders and
  // captions share it.
  static const Color textSecondary = Color(0xFF4F606C);
  static const Color textTertiary = textSecondary;

  /// The one brand header: splash, sign-in, home and balance cards.
  static const List<Color> heroGradient = [primary, primaryDeep];

  // Amber is exclusive to rewards: points, streaks and claim actions.
  static const Color warm = Color(0xFFFFC247);
  static const Color onWarm = Color(0xFF2B1D00);
  static const Color warmSoft = Color(0xFFFFF1D1);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Brushed-aluminium pair: light for hairlines on dark surfaces, mid for
  // secondary icons and rank accents.
  static const Color silverLight = Color(0xFFCBD5E1);
  static const Color silver = Color(0xFF94A3B8);
  static const Color slate = Color(0xFF475569);
  static const Color slateDeep = Color(0xFF334155);

  // Champagne gold marks tier prestige; `goldDeep` is the shade dark enough
  // for text on light surfaces.
  static const Color gold = Color(0xFFC8A252);
  static const Color goldDeep = Color(0xFF835500);
  static const Color goldLight = Color(0xFFE4CD94);

  static const Color bronze = Color(0xFFA9703F);
  static const Color bronzeLight = Color(0xFFDDA877);

  static const Color clay = Color(0xFFC4703F);
  static const Color sand = Color(0xFFD9A84E);
  static const Color sandSoft = Color(0xFFFBF1DC);

  static const Color success = Color(0xFF14704F);
  static const Color successSoft = Color(0xFFE2F1EA);
  static const Color warning = Color(0xFFC98A2B);
  static const Color danger = Color(0xFFAD3F36);
  static const Color dangerSoft = Color(0xFFF8E2DF);

  /// Soft navy shadow that lifts light-mode cards off the canvas.
  static const Color shadowSoft = Color(0x14162B3A);
  static const Color shadowStrong = Color(0x1F000000);

  // Fixed near-black for surfaces that must stay dark regardless of theme
  // brightness: camera viewfinders, image scrims, always-dark chrome.
  static const Color scrim = Color(0xFF05080C);
}
