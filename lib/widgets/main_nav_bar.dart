import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

class MainNavItem {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppIconBuilder icon;
  final AppIconBuilder selectedIcon;
  final String label;
}

class MainNavBar extends StatefulWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  static const double barHeight = 64;
  static const double bubbleSize = 54;

  /// Apex of the selector hop. The widget reserves this much headroom above
  /// the resting bubble, so the arc is never cut by the bar bounds.
  static const double lift = 12;
  static const double _bubbleRest = 28;

  /// Space above the bar: the resting overhang plus the hop headroom.
  static const double overhang = _bubbleRest + lift;

  final List<MainNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> with TickerProviderStateMixin {
  static const Duration _travel = Duration(milliseconds: 300);

  // Horizontal travel and the hop are separate controllers: retargeting while
  // the bubble is mid-air only restarts the hop from an equivalent height, so
  // rapid taps never make the bubble snap down.
  late final AnimationController _slide = AnimationController(
    vsync: this,
    upperBound: (widget.items.length - 1).toDouble(),
    value: widget.currentIndex.toDouble(),
  );
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: _travel,
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
    _slide.animateTo(target, duration: _travel, curve: Curves.easeInOut);
    final phase = _hop.value;
    _hop.forward(from: phase >= 1 ? 0 : (phase > 0.5 ? 1 - phase : phase));
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final count = widget.items.length;

    return SizedBox(
      height: MainNavBar.barHeight + MainNavBar.overhang + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / count;

          return AnimatedBuilder(
            animation: Listenable.merge([_slide, _hop]),
            builder: (context, _) {
              final centerX = _slide.value * itemWidth + itemWidth / 2;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WavePainter(
                        centerX: centerX,
                        top: MainNavBar.overhang,
                      ),
                      child: ClipPath(
                        clipper: _WaveClipper(
                          centerX: centerX,
                          top: MainNavBar.overhang,
                        ),
                        child: const ColoredBox(color: AppColors.surface),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MainNavBar.overhang,
                    height: MainNavBar.barHeight,
                    child: Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(
                            child: _NavButton(
                              item: widget.items[i],
                              selected: widget.currentIndex == i,
                              onTap: () => _select(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: _SelectorBubble(
                        centerX: centerX,
                        hop: _hop.value,
                        item: widget.items[widget.currentIndex],
                        index: widget.currentIndex,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SelectorBubble extends StatelessWidget {
  const new({
    required this.centerX,
    required this.hop,
    required this.item,
    required this.index,
  });

  final double centerX;

  /// 0 to 1 across one hop; 1 is also the resting value.
  final double hop;
  final MainNavItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    // 4t(1-t) is a parabola peaking at 1 mid-hop. A slight stretch while
    // airborne sells the jump without squashing the glyph.
    final arc = 4 * hop * (1 - hop);
    final lifted = MainNavBar.lift * (1 - arc);

    return Transform.translate(
      offset: Offset(centerX - MainNavBar.bubbleSize / 2, lifted),
      child: Transform.scale(
        scaleX: 1 - 0.04 * arc,
        scaleY: 1 + 0.06 * arc,
        child: Container(
          width: MainNavBar.bubbleSize,
          height: MainNavBar.bubbleSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(index),
              child: item.selectedIcon(color: AppColors.background, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const new({required this.item, required this.selected, required this.onTap});

  final MainNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Pressable(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selected ? 0 : 1,
                  child: item.icon(color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Path _waveEdge(Size size, double centerX, double top) {
  const halfWidth = 54.0;
  const depth = 34.0;

  return Path()
    ..moveTo(0, top)
    ..lineTo(centerX - halfWidth, top)
    ..cubicTo(
      centerX - halfWidth * 0.45,
      top,
      centerX - halfWidth * 0.6,
      top + depth,
      centerX,
      top + depth,
    )
    ..cubicTo(
      centerX + halfWidth * 0.6,
      top + depth,
      centerX + halfWidth * 0.45,
      top,
      centerX + halfWidth,
      top,
    )
    ..lineTo(size.width, top);
}

Path _wavePath(Size size, double centerX, double top) {
  return _waveEdge(size, centerX, top)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

class _WaveClipper extends CustomClipper<Path> {
  const new({required this.centerX, required this.top});

  final double centerX;
  final double top;

  @override
  Path getClip(Size size) => _wavePath(size, centerX, top);

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      oldClipper.centerX != centerX || oldClipper.top != top;
}

class _WavePainter extends CustomPainter {
  const new({required this.centerX, required this.top});

  final double centerX;
  final double top;

  // A hairline on the wave edge separates the bar from content without
  // adding a drop shadow.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _waveEdge(size, centerX, top),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.border,
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.centerX != centerX || oldDelegate.top != top;
}
