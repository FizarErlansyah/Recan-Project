import 'package:flutter/foundation.dart';

class HomeNavigation {
  const new _();

  static const int profileTab = 3;

  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  // A command-style name reads better at call sites than a setter.
  // ignore: use_setters_to_change_properties
  static void goTo(int tabIndex) {
    requestedTab.value = tabIndex;
  }
}
