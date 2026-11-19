import 'dart:async';

import 'package:flutter/services.dart';

/// Haptic vocabulary: selection for switching state (tabs, chips, segments),
/// light for committing a primary action. Heavier impacts stay reserved for
/// rewards and are called directly where they happen.
abstract final class Haptics {
  static void selection() => unawaited(HapticFeedback.selectionClick());

  static void light() => unawaited(HapticFeedback.lightImpact());
}
