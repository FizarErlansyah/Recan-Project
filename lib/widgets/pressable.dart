import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';

enum PressHaptic { none, selection, light }

/// Press feedback for something that already owns its tap (an [InkWell], a
/// button): the child shrinks slightly while a finger is down and an optional
/// haptic fires on release.
///
/// It listens to raw pointer events instead of competing in the gesture
/// arena, so it never steals the tap or blocks scrolling; a drag past
/// 12 logical pixels cancels both the scale and the haptic.
class Pressable extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.scale = 0.97,
    this.haptic = PressHaptic.none,
    this.enabled = true,
    this.pressDuration = const Duration(milliseconds: 80),
    this.releaseDuration = const Duration(milliseconds: 140),
  });

  final Widget child;
  final double scale;
  final PressHaptic haptic;
  final bool enabled;
  final Duration pressDuration;
  final Duration releaseDuration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  static const double _slop = 12;

  bool _pressed = false;
  Offset _origin = Offset.zero;

  void _handleDown(PointerDownEvent event) {
    _origin = event.position;
    setState(() => _pressed = true);
  }

  void _handleMove(PointerMoveEvent event) {
    if (_pressed && (event.position - _origin).distance > _slop) {
      setState(() => _pressed = false);
    }
  }

  void _handleUp(PointerUpEvent event) {
    final wasTap = _pressed;
    setState(() => _pressed = false);
    if (!wasTap) return;
    switch (widget.haptic) {
      case PressHaptic.none:
        break;
      case PressHaptic.selection:
        Haptics.selection();
      case PressHaptic.light:
        Haptics.light();
    }
  }

  void _handleCancel(PointerCancelEvent event) {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: _handleUp,
      onPointerCancel: _handleCancel,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? widget.scale : 1,
        duration: _pressed ? widget.pressDuration : widget.releaseDuration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
