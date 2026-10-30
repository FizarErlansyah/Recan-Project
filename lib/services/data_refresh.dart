import 'package:flutter/foundation.dart';

class DataRefresh {
  const new _();

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChanged() {
    revision.value += 1;
  }
}
