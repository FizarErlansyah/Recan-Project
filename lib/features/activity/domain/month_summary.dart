import 'package:mobile_apps_recan/models/activity_transaction.dart';

/// What came in and went out during one calendar month.
class MonthSummary {
  const new({
    required this.pointsIn,
    required this.pointsOut,
    required this.cans,
  });

  factory of(Iterable<ActivityTransaction> rows, DateTime month) {
    var pointsIn = 0;
    var pointsOut = 0;
    var cans = 0;
    for (final row in rows) {
      final at = row.timestamp;
      if (at.year != month.year || at.month != month.month) continue;
      if (row.points > 0) {
        pointsIn += row.points;
      } else {
        pointsOut -= row.points;
      }
      cans += row.cans;
    }
    return MonthSummary(pointsIn: pointsIn, pointsOut: pointsOut, cans: cans);
  }

  final int pointsIn;
  final int pointsOut;
  final int cans;
}
