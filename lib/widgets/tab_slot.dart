import 'package:flutter/material.dart';

/// One tab of the home shell. Switching crossfades instead of cutting, and a
/// fully hidden slot goes [Offstage] so it is neither painted nor hit-tested
/// while its state stays alive.
class TabSlot extends StatefulWidget {
  const new({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  @override
  State<TabSlot> createState() => _TabSlotState();
}

class _TabSlotState extends State<TabSlot> with SingleTickerProviderStateMixin {
  static const Duration _fade = Duration(milliseconds: 160);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fade,
    value: widget.active ? 1 : 0,
  );

  @override
  void didUpdateWidget(TabSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    final target = widget.active ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = target;
    } else {
      _controller.animateTo(target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TickerMode sits inside the fade so pausing a hidden tab's animations
    // never freezes the fade that is hiding it.
    final page = TickerMode(enabled: widget.active, child: widget.child);

    return AnimatedBuilder(
      animation: _controller,
      child: page,
      builder: (context, child) => Offstage(
        offstage: _controller.value == 0,
        child: IgnorePointer(
          ignoring: !widget.active,
          child: ExcludeSemantics(
            excluding: !widget.active,
            child: FadeTransition(opacity: _controller, child: child),
          ),
        ),
      ),
    );
  }
}
