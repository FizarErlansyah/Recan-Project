import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum ActivityFilter {
  all,
  deposit,
  redeem,
  reward;

  String get label => switch (this) {
    all => tr('Semua', 'All'),
    deposit => tr('Setoran', 'Deposits'),
    redeem => tr('Tukar', 'Spent'),
    reward => tr('Hadiah', 'Rewards'),
  };

  bool keeps(ActivityTransaction row) => switch (this) {
    all => true,
    deposit => row.type == ActivityType.deposit,
    redeem => row.type == ActivityType.redeem,
    reward =>
      row.type != ActivityType.deposit && row.type != ActivityType.redeem,
  };
}
