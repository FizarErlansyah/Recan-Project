import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';

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
  static const double overhang = 28;
  static const double bubbleSize = 54;

  final List<MainNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    upperBound: (widget.items.length - 1).toDouble(),
    value: widget.currentIndex.toDouble(),
  );

  @override
  void didUpdateWidget(MainNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.animateTo(
        widget.currentIndex.toDouble(),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            animation: _controller,
            builder: (context, _) {
              final centerX = _controller.value * itemWidth + itemWidth / 2;

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
                              onTap: () => widget.onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: centerX - MainNavBar.bubbleSize / 2,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: MainNavBar.bubbleSize,
                        height: MainNavBar.bubbleSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: KeyedSubtree(
                            key: ValueKey(widget.currentIndex),
                            child: widget.items[widget.currentIndex]
                                .selectedIcon(
                                  color: AppColors.background,
                                  size: 22,
                                ),
                          ),
                        ),
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
      child: InkWell(
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
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
