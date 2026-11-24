import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum CarbonRange {
  week,
  month,
  sinceJan2025;

  String get label => switch (this) {
    week => tr('7 Hari', '7 Days'),
    month => tr('Bulanan', 'Monthly'),
    sinceJan2025 => tr('Sejak 2025', 'Since 2025'),
  };

  String get subtitle => switch (this) {
    week => tr(
      'Karbon yang dihemat komunitas 7 hari terakhir',
      'Carbon saved by the community in the last 7 days',
    ),
    month => tr(
      'Karbon yang dihemat komunitas bulan ini per minggu',
      'Carbon saved by the community this month, week by week',
    ),
    sinceJan2025 => tr(
      'Akumulasi karbon yang dihemat komunitas sejak 1 Jan 2025',
      'Cumulative carbon saved by the community since Jan 1, 2025',
    ),
  };

  String get totalLabel => switch (this) {
    week => tr('Total 7 hari', 'Total 7 days'),
    month => tr('Total bulan ini', 'Total this month'),
    sinceJan2025 => tr('Total sejak Jan 2025', 'Total since Jan 2025'),
  };

  int get goalCans => switch (this) {
    week => 700,
    month => 3000,
    sinceJan2025 => 45000,
  };
}

class CarbonPoint {
  const new({required this.labelId, required this.labelEn, required this.cans});

  /// One bar of the 7-day chart; [weekday] follows DateTime (1 = Monday).
  factory weekday({required int weekday, required int cans}) => CarbonPoint(
    labelId: _weekdaysId[weekday - 1],
    labelEn: _weekdaysEn[weekday - 1],
    cans: cans,
  );

  /// One bar of the monthly chart; [week] counts from 1.
  factory weekOfMonth({required int week, required int cans}) =>
      CarbonPoint(labelId: 'Mg $week', labelEn: 'W$week', cans: cans);

  /// One bar of the since-2025 chart.
  factory month({required int year, required int month, required int cans}) {
    final yy = year % 100;
    return CarbonPoint(
      labelId: '${_monthsId[month - 1]} $yy',
      labelEn: '${_monthsEn[month - 1]} $yy',
      cans: cans,
    );
  }

  /// Reads a row of the `community_carbon_summary` view.
  factory fromSummaryRow(CarbonRange range, Map<String, dynamic> json) {
    final cans = (json['cans'] as num).toInt();
    final start = DateTime.parse(json['bucket_start'] as String);
    return switch (range) {
      CarbonRange.week => CarbonPoint.weekday(
        weekday: start.weekday,
        cans: cans,
      ),
      CarbonRange.month => CarbonPoint.weekOfMonth(
        week: (json['bucket_index'] as num).toInt(),
        cans: cans,
      ),
      CarbonRange.sinceJan2025 => CarbonPoint.month(
        year: start.year,
        month: start.month,
        cans: cans,
      ),
    };
  }

  static const List<String> _weekdaysId = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const List<String> _weekdaysEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _monthsId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const List<String> _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final String labelId;
  final String labelEn;
  final int cans;

  String get label => tr(labelId, labelEn);

  double get carbonKg => cans * DropSessionSummary.carbonKgPerCan;
}

class CarbonImpact {
  const new({required this.range, required this.points});

  factory fromSummary(CarbonRange range, List<Map<String, dynamic>> rows) =>
      CarbonImpact(
        range: range,
        points: [
          for (final row in rows) CarbonPoint.fromSummaryRow(range, row),
        ],
      );

  final CarbonRange range;
  final List<CarbonPoint> points;

  int get totalCans => points.fold(0, (sum, point) => sum + point.cans);

  double get totalCarbonKg => totalCans * DropSessionSummary.carbonKgPerCan;

  int get targetPercent =>
      (totalCans / range.goalCans * 100).clamp(0, 100).round();
}
