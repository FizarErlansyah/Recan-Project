import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Lets a widget accept either a Material [IconData] or a Hugeicons SVG path
/// list behind one signature, since the two are not assignable to each
/// other's type.
typedef AppIconBuilder = Widget Function({
  required Color color,
  required double size,
});

AppIconBuilder materialIcon(IconData data) =>
    ({required color, required size}) => Icon(data, color: color, size: size);

AppIconBuilder hugeIcon(List<List<dynamic>> data) =>
    ({required color, required size}) =>
        HugeIcon(icon: data, color: color, size: size);
