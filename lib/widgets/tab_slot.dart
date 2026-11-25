import 'package:flutter/material.dart';

/// One tab of the home shell. Switching slides in from the side the tab sits
/// on, cross-fading with a slight scale, and a fully hidden slot goes
/// [Offstage] so it is neither painted nor hit-tested while its state stays
/// alive.
class TabSlot extends StatefulWidget {
  const new({
    required this.active,
    required this.child,
    super.key,
    this.side = 0,
  });

  static const Duration duration = Duration(milliseconds: 300);
  static const double restScale = 0.985;

  /// Share of the width a tab travels.
  static const double _travel = 0.08;

  final bool active;

  /// Where a hidden tab waits: -1 left of the open one, 1 right of it.
  final int side;
  final Widget child;

  @override
  State<TabSlot> createState() => _TabSlotState();
}

class _TabSlotState extends State<TabSlot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TabSlot.duration,
    value: widget.active ? 1 : 0,
  );

  // The side is remembered, so the tab being opened enters from where it was.
  late int _side = widget.side;

  @override
  void didUpdateWidget(TabSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _side = widget.side;
    } else if (!oldWidget.active) {
      _side = oldWidget.side;
    }
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
    // TickerMode sits inside the transition so pausing a hidden tab's
    // animations never freezes the motion that is hiding it.
    // Hidden tabs also keep their heroes out of route transitions.
    final page = HeroMode(
      enabled: widget.active,
      child: TickerMode(enabled: widget.active, child: widget.child),
    );

    return AnimatedBuilder(
      animation: _controller,
      child: page,
      builder: (context, child) => Offstage(
        offstage: _controller.value == 0,
        child: IgnorePointer(
          ignoring: !widget.active,
          child: ExcludeSemantics(
            excluding: !widget.active,
            child: _Glide(
              progress: _controller.value,
              side: _side,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}

class _Glide extends StatelessWidget {
  const new({required this.progress, required this.side, required this.child});

  /// 0 hidden, 1 settled.
  final double progress;
  final int side;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The same ease both ways, so the two tabs move as one sheet.
    final t = Curves.easeOutCubic.transform(progress);
    const rest = TabSlot.restScale;

    return FractionalTranslation(
      translation: Offset(side * (1 - t) * TabSlot._travel, 0),
      child: Transform.scale(
        scale: rest + (1 - rest) * t,
        child: Opacity(opacity: t, child: child),
      ),
    );
  }
}
