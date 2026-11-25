import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';

/// The white brand mark that travels between screens: from the splash to the
/// balance card for a signed-in user, or to the sign-in header otherwise.
class BrandHero extends StatelessWidget {
  const new({required this.size, super.key});

  static const String tag = 'recan-brandmark';
  static const String asset = 'assets/images/recan_mark_white.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: ReCanLogo(size: size, asset: asset),
    );
  }
}
