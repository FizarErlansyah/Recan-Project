/// The calendar the server counts days on (Asia/Jakarta). WIB has no daylight
/// saving, so a fixed offset is exact and needs no time zone database.
abstract final class WibCalendar {
  static const Duration offset = Duration(hours: 7);

  /// The Jakarta calendar date of [instant], as a UTC midnight value so two
  /// dates compare without any device time zone involved.
  static DateTime dayOf(DateTime instant) {
    final local = instant.toUtc().add(offset);
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// The instant of the coming 00:00 WIB.
  static DateTime nextMidnight(DateTime instant) =>
      dayOf(instant).add(const Duration(days: 1)).subtract(offset);
}
