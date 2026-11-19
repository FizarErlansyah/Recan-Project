import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Lets a widget take an icon as a deferred builder, so the caller picks the
/// glyph and the widget picks colour and size for its own state.
typedef AppIconBuilder = Widget Function({
  required Color color,
  required double size,
});

AppIconBuilder hugeIcon(List<List<dynamic>> data) =>
    ({required color, required size}) =>
        HugeIcon(icon: data, color: color, size: size);
