import 'package:flutter/material.dart';

/// Fades and lifts its child into place once, after a wait that grows with
/// [index], so a column of them arrives in reading order.
class StaggeredEntrance extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.index = 0,
    this.delay,
    this.rise = 20,
  });

  static const Duration step = Duration(milliseconds: 70);
  static const Duration duration = Duration(milliseconds: 420);

  final Widget child;
  final int index;

  /// Replaces the wait derived from [index].
  final Duration? delay;

  /// Distance travelled upward, in logical pixels.
  final double rise;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final Duration _wait =
      widget.delay ?? StaggeredEntrance.step * widget.index;
  late final Duration _total = _wait + StaggeredEntrance.duration;

  // The wait is part of the animation rather than a Timer, so nothing is left
  // pending when the widget goes away and a test can settle it.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _wait.inMicroseconds / _total.inMicroseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  // Scrolled out of a lazy list and back, the section would otherwise arrive
  // a second time.
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, widget.rise * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}
