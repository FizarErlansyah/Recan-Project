/// Shared points/currency number formatting, used across catalog, checkout,
/// profile and activity screens. Kept here (its original home) rather than
/// moved, since a rename would touch every call site for no behavior change.
class PointsHeader {
  const new _();

  static const int rupiahPerPoint = 1;

  static String formatNumber(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
