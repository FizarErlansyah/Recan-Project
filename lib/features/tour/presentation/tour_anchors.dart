import 'package:flutter/widgets.dart';
import 'package:mobile_apps_recan/features/tour/domain/tour_step.dart';

/// The keys the tour uses to find its targets. One set belongs to one home
/// shell, so two shells in a route transition never share a key.
class TourAnchors {
  final GlobalKey balance = GlobalKey(debugLabel: 'tour-balance');
  final GlobalKey redeem = GlobalKey(debugLabel: 'tour-redeem');
  final GlobalKey missions = GlobalKey(debugLabel: 'tour-missions');
  final GlobalKey stations = GlobalKey(debugLabel: 'tour-stations');
  final GlobalKey education = GlobalKey(debugLabel: 'tour-education');
  final GlobalKey activityTab = GlobalKey(debugLabel: 'tour-activity');
  final GlobalKey profileTab = GlobalKey(debugLabel: 'tour-profile');

  /// Everything lit for [target]; the spotlight spans all of it.
  List<GlobalKey> keysOf(TourTarget target) => switch (target) {
    TourTarget.balance => [balance],
    TourTarget.redeem => [redeem],
    TourTarget.missions => [missions],
    TourTarget.stations => [stations],
    TourTarget.education => [education],
    TourTarget.tabs => [activityTab, profileTab],
  };
}
