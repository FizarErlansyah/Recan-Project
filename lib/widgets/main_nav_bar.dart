import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

class MainNavItem {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.anchor,
  });

  /// Outline shown while the tab is closed.
  final AppIconBuilder icon;

  /// Filled version carried by the bubble while it is open.
  final AppIconBuilder selectedIcon;
  final String label;

  /// Marks the tab for something that needs to find it on screen.
  final Key? anchor;
}

/// A bar notched under a floating bubble that hops between equal tabs. The
/// space above the bar is see-through, so the page scrolls behind it.
class MainNavBar extends StatefulWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  static const double barHeight = 64;
  static const double bubbleSize = 54;

  /// Apex of the hop, reserved above the resting bubble so it is never cut.
  static const double lift = 12;

  /// Space above the bar: the resting overhang plus the hop headroom.
  static const double overhang = 28 + lift;

  final List<MainNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> with TickerProviderStateMixin {
  static const Duration _hopTime = Duration(milliseconds: 460);

  // Slightly under-damped: one soft pass beyond the tab, then rest.
  static final SpringDescription _spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 380,
    ratio: 0.72,
  );

  /// Where the bubble is, in tabs.
  late final AnimationController _slide = AnimationController.unbounded(
    vsync: this,
    value: widget.currentIndex.toDouble(),
  );
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: _hopTime,
    value: 1,
  );

  @override
  void didUpdateWidget(MainNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    final target = widget.currentIndex.toDouble();
    if (MediaQuery.disableAnimationsOf(context)) {
      _slide.value = target;
      _hop.value = 1;
      return;
    }
    // Starting from the current place and speed keeps rapid taps fluid.
    _slide.animateWith(
      SpringSimulation(
        _spring,
        _slide.value,
        target,
        _slide.velocity,
        snapToEnd: true,
      ),
    );
    _hop.forward(from: _Hop.resume(_hop.value));
  }

  @override
  void dispose() {
    _slide.dispose();
    _hop.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == widget.currentIndex) return;
    Haptics.selection();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final height =
        MainNavBar.barHeight +
        MainNavBar.overhang +
        MediaQuery.paddingOf(context).bottom;

    // The bar has a fixed height, so its labels stop growing before they
    // would spill out of it.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) => _frames(constraints.maxWidth),
        ),
      ),
    );
  }

  Widget _frames(double width) {
    final slot = width / widget.items.length;

    return AnimatedBuilder(
      animation: Listenable.merge([_slide, _hop]),
      child: Positioned(
        left: 0,
        right: 0,
        top: MainNavBar.overhang,
        height: MainNavBar.barHeight,
        child: _Tabs(
          items: widget.items,
          current: widget.currentIndex,
          onSelect: _select,
        ),
      ),
      builder: (context, tabs) => _Layers(
        centerX: (_slide.value + 0.5) * slot,
        height: _Hop.height(_hop.value),
        item: widget.items[widget.currentIndex],
        index: widget.currentIndex,
        tabs: tabs!,
      ),
    );
  }
}

/// One hop over its run, as a share of [MainNavBar.lift]: up and down, then a
/// small give on landing.
abstract final class _Hop {
  static const double _landing = 0.76;
  static const double _give = 0.2;

  static double height(double t) => t < _landing
      ? math.sin(math.pi * t / _landing)
      : -_give * math.sin(math.pi * (t - _landing) / (1 - _landing));

  /// Where a new hop starts, so a bubble already in the air does not drop.
  static double resume(double t) =>
      t < _landing ? math.min(t, _landing - t) : 0;
}

class _Layers extends StatelessWidget {
  const new({
    required this.centerX,
    required this.height,
    required this.item,
    required this.index,
    required this.tabs,
  });

  final double centerX;
  final double height;
  final MainNavItem item;
  final int index;
  final Widget tabs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _NotchPainter(
              centerX: centerX,
              fill: context.palette.surface,
              line: context.palette.border,
            ),
          ),
        ),
        tabs,
        Positioned(
          left: centerX - MainNavBar.bubbleSize / 2,
          top: MainNavBar.lift * (1 - height),
          child: _Bubble(item: item, index: index, stretch: height),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const new({required this.item, required this.index, required this.stretch});

  final MainNavItem item;
  final int index;

  /// Positive while airborne, negative as it lands.
  final double stretch;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      // Anchored at the top so the stretch grows into the bar, never above it.
      alignment: Alignment.topCenter,
      scaleX: 1 - 0.05 * stretch,
      scaleY: 1 + 0.07 * stretch,
      child: Container(
        key: const ValueKey('nav-bubble'),
        width: MainNavBar.bubbleSize,
        height: MainNavBar.bubbleSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.palette.primary,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: _BubbleIcon(item: item, index: index),
      ),
    );
  }
}

class _BubbleIcon extends StatelessWidget {
  const new({required this.item, required this.index});

  final MainNavItem item;
  final int index;

  static Widget _pop(Widget child, Animation<double> animation) =>
      ScaleTransition(
        scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      );

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: still ? Duration.zero : const Duration(milliseconds: 220),
      transitionBuilder: _pop,
      child: KeyedSubtree(
        key: ValueKey('nav-filled-$index'),
        child: item.selectedIcon(color: context.palette.onPrimary, size: 24),
      ),
    );
  }
}

class _NotchPainter extends CustomPainter {
  const new({required this.centerX, required this.fill, required this.line});

  static const double _halfWidth = 54;
  static const double _depth = 34;

  final double centerX;
  final Color fill;
  final Color line;

  Path _edge(Size size) {
    const top = MainNavBar.overhang;

    return Path()
      ..moveTo(math.min(0, centerX - _halfWidth), top)
      ..lineTo(centerX - _halfWidth, top)
      ..cubicTo(
        centerX - _halfWidth * 0.45,
        top,
        centerX - _halfWidth * 0.6,
        top + _depth,
        centerX,
        top + _depth,
      )
      ..cubicTo(
        centerX + _halfWidth * 0.6,
        top + _depth,
        centerX + _halfWidth * 0.45,
        top,
        centerX + _halfWidth,
        top,
      )
      ..lineTo(math.max(size.width, centerX + _halfWidth), top);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edge = _edge(size);
    final end = math.max(size.width, centerX + _halfWidth);
    final body = Path.from(edge)
      ..lineTo(end, size.height)
      ..lineTo(math.min(0, centerX - _halfWidth), size.height)
      ..close();

    canvas
      // A soft lift lets the bar read over content scrolling behind it.
      ..drawPath(
        body.shift(const Offset(0, -2)),
        Paint()
          ..color = AppColors.shadowStrong
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )
      ..drawPath(body, Paint()..color = fill)
      ..drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = line,
      );
  }

  // Taps above the bar belong to the page showing through there.
  @override
  bool hitTest(Offset position) => position.dy >= MainNavBar.overhang;

  @override
  bool shouldRepaint(_NotchPainter oldDelegate) =>
      oldDelegate.centerX != centerX ||
      oldDelegate.fill != fill ||
      oldDelegate.line != line;
}

class _Tabs extends StatelessWidget {
  const new({
    required this.items,
    required this.current,
    required this.onSelect,
  });

  final List<MainNavItem> items;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in items.indexed)
          Expanded(
            child: KeyedSubtree(
              key: item.anchor,
              child: _NavButton(
                item: item,
                index: index,
                selected: current == index,
                onTap: () => onSelect(index),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const new({
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final MainNavItem item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        scale: 0.92,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _NavFace(item: item, index: index, selected: selected),
        ),
      ),
    );
  }
}

class _NavFace extends StatelessWidget {
  const new({required this.item, required this.index, required this.selected});

  final MainNavItem item;
  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            child: _SlotIcon(item: item, index: index, hidden: selected),
          ),
          const SizedBox(height: 4),
          _NavLabel(label: item.label, selected: selected),
        ],
      ),
    );
  }
}

/// The outline icon, which gives up its place once the bubble takes it.
class _SlotIcon extends StatelessWidget {
  const new({required this.item, required this.index, required this.hidden});

  final MainNavItem item;
  final int index;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: still ? Duration.zero : const Duration(milliseconds: 220),
      child: hidden
          ? const SizedBox.shrink()
          : KeyedSubtree(
              key: ValueKey('nav-outline-$index'),
              child: item.icon(color: context.palette.textSecondary, size: 24),
            ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const new({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: selected
            ? context.palette.accent
            : context.palette.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
