import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class CurvedNavItem {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class CurvedNavBar extends StatefulWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  static const double barHeight = 64;
  static const double overhang = 28;
  static const double bubbleSize = 56;

  final List<CurvedNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<CurvedNavBar> createState() => _CurvedNavBarState();
}

class _CurvedNavBarState extends State<CurvedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    upperBound: (widget.items.length - 1).toDouble(),
    value: widget.currentIndex.toDouble(),
  );

  @override
  void didUpdateWidget(CurvedNavBar oldWidget) {
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final textTheme = Theme.of(context).textTheme;
    final count = widget.items.length;

    return SizedBox(
      height: CurvedNavBar.barHeight + CurvedNavBar.overhang + bottomInset,
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
                        top: CurvedNavBar.overhang,
                      ),
                      child: ClipPath(
                        clipper: _WaveClipper(
                          centerX: centerX,
                          top: CurvedNavBar.overhang,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: ColoredBox(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: CurvedNavBar.overhang,
                    height: CurvedNavBar.barHeight,
                    child: Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(
                            child: _NavButton(
                              item: widget.items[i],
                              selected: widget.currentIndex == i,
                              textTheme: textTheme,
                              onTap: () => widget.onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: centerX - CurvedNavBar.bubbleSize / 2,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: CurvedNavBar.bubbleSize,
                        height: CurvedNavBar.bubbleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary,
                          border: Border.all(
                            color: AppColors.primarySoft.withValues(
                              alpha: 0.35,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowStrong,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            widget.items[widget.currentIndex].selectedIcon,
                            key: ValueKey(widget.currentIndex),
                            size: 28,
                            color: AppColors.primarySoft,
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
  const new({
    required this.item,
    required this.selected,
    required this.textTheme,
    required this.onTap,
  });

  final CurvedNavItem item;
  final bool selected;
  final TextTheme textTheme;
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
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 0 : 1,
                child: Icon(
                  item.icon,
                  size: 24,
                  color: AppColors.primarySoft.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: selected
                      ? AppColors.primarySoft
                      : AppColors.primarySoft.withValues(alpha: 0.7),
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

Path _wavePath(Size size, double centerX, double top) {
  const halfWidth = 56.0;
  const depth = 36.0;

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
    ..lineTo(size.width, top)
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

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
      _wavePath(size, centerX, top),
      AppColors.textPrimary,
      10,
      false,
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.centerX != centerX || oldDelegate.top != top;
}
