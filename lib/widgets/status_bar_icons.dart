import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sets the status bar icon brightness for the region it wraps.
///
/// The system keeps the last style it received when no region sits under the
/// status bar, so any screen with a dark or emerald top edge must opt in to
/// light icons and the app shell must restore dark icons for everything else.
class StatusBarIcons extends StatelessWidget {
  const new({required this.light, required this.child, super.key});

  final bool light;
  final Widget child;

  static const SystemUiOverlayStyle _lightIcons = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
  static const SystemUiOverlayStyle _darkIcons = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: light ? _lightIcons : _darkIcons,
      child: child,
    );
  }
}
