import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

const int _gramsPerKilogram = 1000;
const int _gramsPerHundredthKilogram = 10;
const int _hundredthsPerKilogram = 100;

/// Stays in grams below 1 kg so a single 14 g can never rounds to "0,0 kg".
/// At 1 kg and above it shows up to two decimals with trailing zeros dropped.
String formatWeight(num grams) {
  final wholeGrams = grams.round();
  if (wholeGrams < _gramsPerKilogram) return '$wholeGrams g';

  // Integer hundredths avoid floating-point drift at the 1 kg boundary.
  final hundredths = (wholeGrams / _gramsPerHundredthKilogram).round();
  final kilograms = hundredths ~/ _hundredthsPerKilogram;
  final fraction = (hundredths % _hundredthsPerKilogram)
      .toString()
      .padLeft(2, '0')
      .replaceFirst(RegExp(r'0+$'), '');

  final integer = PointsHeader.formatNumber(kilograms)
      .replaceAll('.', tr('.', ','));
  return fraction.isEmpty
      ? '$integer kg'
      : '$integer${tr(',', '.')}$fraction kg';
}
