import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class PulsingStatusDot extends StatefulWidget {
  const new({super.key, this.size = 8, this.color = AppColors.sageLight});

  final double size;
  final Color color;

  @override
  State<PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(
                alpha: 0.2 + 0.5 * _controller.value,
              ),
              blurRadius: 4 + 6 * _controller.value,
            ),
          ],
        ),
      ),
    );
  }
}
