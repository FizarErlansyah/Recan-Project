import 'package:mobile_apps_recan/features/rewards/domain/wib_calendar.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';

class DayDeposit {
  const new({required this.date, required this.cans});

  /// Jakarta calendar date, as a UTC midnight value.
  final DateTime date;
  final int cans;
}

/// Cans the user deposited on each of the last seven Jakarta days.
class WeeklyDeposits {
  const new(this.days);

  factory from(Iterable<ActivityTransaction> activities, DateTime now) {
    final today = WibCalendar.dayOf(now);
    final perDay = {
      for (var back = length - 1; back >= 0; back--)
        today.subtract(Duration(days: back)): 0,
    };
    for (final activity in activities) {
      if (activity.type != ActivityType.deposit) continue;
      final day = WibCalendar.dayOf(activity.timestamp);
      final soFar = perDay[day];
      if (soFar != null) perDay[day] = soFar + activity.cans;
    }
    return WeeklyDeposits([
      for (final MapEntry(:key, :value) in perDay.entries)
        DayDeposit(date: key, cans: value),
    ]);
  }

  static const int length = 7;

  /// Oldest first; the last one is today.
  final List<DayDeposit> days;

  int get total => days.fold(0, (sum, day) => sum + day.cans);

  int get peak => days.fold(0, (top, day) => day.cans > top ? day.cans : top);
}
