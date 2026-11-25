import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

/// Tactile press for buttons and cards: a soft shrink under the finger and,
/// when [haptic] is on, a light tap once the press turns into a real one (not
/// into a scroll).
///
/// Give [onTap] when the child has no tap of its own. Leave it out around an
/// [InkWell] or a button, which keeps handling the tap.
class BouncyTap extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onTap,
    this.haptic = false,
    this.enabled = true,
  });

  static const double pressedScale = 0.96;
  static const Duration pressDuration = Duration(milliseconds: 120);

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    return Pressable(
      enabled: enabled,
      scale: pressedScale,
      pressDuration: pressDuration,
      releaseDuration: pressDuration,
      haptic: haptic ? PressHaptic.light : PressHaptic.none,
      child: tap == null
          ? child
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? tap : null,
              child: child,
            ),
    );
  }
}
