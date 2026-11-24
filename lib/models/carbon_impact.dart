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

  final String labelId;
  final String labelEn;
  final int cans;

  String get label => tr(labelId, labelEn);

  double get carbonKg => cans * DropSessionSummary.carbonKgPerCan;
}

class CarbonImpact {
  const new({required this.range, required this.points});

  final CarbonRange range;
  final List<CarbonPoint> points;

  int get totalCans => points.fold(0, (sum, point) => sum + point.cans);

  double get totalCarbonKg => totalCans * DropSessionSummary.carbonKgPerCan;

  int get targetPercent =>
      (totalCans / range.goalCans * 100).clamp(0, 100).round();
}
