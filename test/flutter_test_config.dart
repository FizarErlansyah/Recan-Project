import 'dart:async';

import 'package:mobile_apps_recan/features/tour/data/tour_store.dart';

import 'support/tour_stores.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TourStore.current = const FinishedTourStore();
  await testMain();
}
