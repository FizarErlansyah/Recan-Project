import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';

/// A deliberate gesture for an action that cannot be undone: the thumb must be
/// dragged almost to the end, so a stray tap in front of the cashier does
/// nothing.
class SwipeToConfirm extends StatefulWidget {
  const new({required this.label, required this.onConfirmed, super.key});

  final String label;

  /// False springs the thumb back so the holder can try again.
  final Future<bool> Function() onConfirmed;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 0.85;
  static const Duration _settle = Duration(milliseconds: 220);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _settle,
  );
  bool _busy = false;

  void _drag(double delta, double travel) {
    if (_busy) return;
    _progress.value += delta / travel;
  }

  Future<void> _release() async {
    if (_busy) return;
    if (_progress.value < _threshold) {
      _moveTo(0);
      return;
    }
    await _confirm();
  }

  Future<void> _confirm() async {
    if (_busy) return;
    Haptics.light();
    setState(() => _busy = true);
    _moveTo(1);
    final done = await widget.onConfirmed();
    if (!mounted || done) return;
    setState(() => _busy = false);
    _moveTo(0);
  }

  void _moveTo(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _progress.value = target;
    } else {
      _progress.animateTo(target, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen readers cannot drag, so activating the control confirms.
    return Semantics(
      button: true,
      label: widget.label,
      onTap: _confirm,
      child: _Track(
        progress: _progress,
        label: widget.label,
        busy: _busy,
        onDrag: _drag,
        onRelease: _release,
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const new({
    required this.progress,
    required this.label,
    required this.busy,
    required this.onDrag,
    required this.onRelease,
  });

  static const double _thumb = 52;
  static const double _inset = 4;

  final Animation<double> progress;
  final String label;
  final bool busy;
  final void Function(double delta, double travel) onDrag;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxWidth - _thumb - _inset * 2;
        return Container(
          constraints: const BoxConstraints(minHeight: _thumb + _inset * 2),
          decoration: ShapeDecoration(
            color: context.palette.tint,
            shape: const StadiumBorder(),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              _Label(label: label),
              _Slider(
                progress: progress,
                travel: travel,
                inset: _inset,
                onDrag: (delta) => onDrag(delta, travel),
                onRelease: onRelease,
                child: _Thumb(size: _thumb, busy: busy),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Places the thumb along the track and turns drags into progress.
class _Slider extends StatelessWidget {
  const new({
    required this.progress,
    required this.travel,
    required this.inset,
    required this.onDrag,
    required this.onRelease,
    required this.child,
  });

  final Animation<double> progress;
  final double travel;
  final double inset;
  final ValueChanged<double> onDrag;
  final VoidCallback onRelease;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, handle) => Padding(
        padding: EdgeInsets.only(left: inset + travel * progress.value),
        child: handle,
      ),
      child: GestureDetector(
        key: const ValueKey('swipe-thumb'),
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) => onRelease(),
        child: child,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 8, 16, 8),
      child: ExcludeSemantics(
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: context.palette.accent),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const new({required this.size, required this.busy});

  final double size;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.palette.primary,
      ),
      child: busy
          ? SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.palette.onPrimary,
              ),
            )
          : HugeIcon(
              icon: AppIcons.chevronRight,
              color: context.palette.onPrimary,
            ),
    );
  }
}
