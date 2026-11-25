import 'package:flutter/foundation.dart';

class HomeNavigation {
  const new _();

  static const int activityTab = 2;
  static const int profileTab = 3;

  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  /// Counts requests to show the app tour again.
  static final ValueNotifier<int> tourRequests = ValueNotifier<int>(0);

  static void replayTour() => tourRequests.value++;

  // A command-style name reads better at call sites than a setter.
  // ignore: use_setters_to_change_properties
  static void goTo(int tabIndex) {
    requestedTab.value = tabIndex;
  }
}
