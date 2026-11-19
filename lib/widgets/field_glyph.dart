import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

/// Leading icon for an [InputDecoration]. The decorator gives its prefix a
/// 48dp minimum box, which would stretch a bare [HugeIcon] to fill it, so the
/// glyph is centred inside a shrink-wrapped [Center] instead.
class FieldGlyph extends StatelessWidget {
  const new({required this.icon, super.key, this.color});

  final IconGlyph icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: HugeIcon(
        icon: icon,
        size: 20,
        color: color ?? context.palette.textSecondary,
      ),
    );
  }
}
