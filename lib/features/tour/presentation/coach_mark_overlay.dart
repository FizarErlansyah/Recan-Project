import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/features/tour/domain/tour_step.dart';
import 'package:mobile_apps_recan/features/tour/presentation/tour_anchors.dart';
import 'package:mobile_apps_recan/features/tour/presentation/tour_card.dart';
import 'package:mobile_apps_recan/utils/haptics.dart';

/// Dims the app, leaves one part of it lit and explains it. It sits over the
/// shell and swallows every touch outside its own card.
class CoachMarkOverlay extends StatefulWidget {
  const new({required this.anchors, required this.onDone, super.key});

  final TourAnchors anchors;

  /// Finished or skipped.
  final VoidCallback onDone;

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay> {
  // The page may still be sliding in; it counts as settled once the target has
  // held still for this many frames.
  static const int _stillFrames = 3;

  int _index = 0;
  Rect? _hole;
  int _held = 0;
  bool _tracking = false;

  TourStep get _step => TourStep.home[_index];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also runs on rotation or a text size change, which move the targets.
    MediaQuery.of(context);
    _reveal();
  }

  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = widget.anchors.keysOf(_step.target).first.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, alignment: 0.5);
      }
      _held = 0;
      if (!_tracking) _track();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _track() {
    _tracking = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (!mounted) return;
        final hole = _measure();
        if (hole == _hole) {
          _held++;
        } else {
          _held = 0;
          setState(() => _hole = hole);
        }
        if (_held < _stillFrames) {
          _track();
        } else {
          _tracking = false;
        }
      })
      ..scheduleFrame();
  }

  Rect? _measure() {
    final own = context.findRenderObject();
    if (own is! RenderBox || !own.hasSize) return null;
    final origin = own.localToGlobal(Offset.zero);
    Rect? union;
    for (final key in widget.anchors.keysOf(_step.target)) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final rect = box.localToGlobal(Offset.zero) - origin & box.size;
      union = union?.expandToInclude(rect) ?? rect;
    }
    return union?.intersect(Offset.zero & own.size);
  }

  void _goTo(int index) {
    Haptics.selection();
    setState(() => _index = index);
    _reveal();
  }

  void _next() {
    if (_index == TourStep.home.length - 1) {
      widget.onDone();
    } else {
      _goTo(_index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _Stage(
          hole: _hole,
          card: TourCard(
            key: const ValueKey('tour-card'),
            step: _step,
            index: _index,
            total: TourStep.home.length,
            onNext: _next,
            onBack: () => _goTo(_index - 1),
            onSkip: widget.onDone,
          ),
        ),
      ),
    );
  }
}

/// The scrim with its spotlight, and the card placed clear of it.
class _Stage extends StatelessWidget {
  const new({required this.hole, required this.card});

  final Rect? hole;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Spotlight(hole: hole),
          _CardSlot(hole: hole, child: card),
        ],
      ),
    );
  }
}

class _Spotlight extends StatelessWidget {
  const new({required this.hole});

  final Rect? hole;

  static Widget _paint(Rect? lit) => CustomPaint(
    key: const ValueKey('tour-spotlight'),
    painter: TourSpotlightPainter(lit),
  );

  @override
  Widget build(BuildContext context) {
    final target = hole;
    // A tween needs somewhere to go; until the first target is measured there
    // is only the plain scrim.
    if (target == null) return _paint(null);
    final still = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<Rect?>(
      tween: RectTween(begin: target, end: target),
      duration: still ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (_, lit, _) => _paint(lit),
    );
  }
}

class TourSpotlightPainter extends CustomPainter {
  const new(this.hole);

  static const double _margin = 6;
  static const double _stroke = 2;

  /// The part left lit, in overlay coordinates.
  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = AppColors.scrim.withValues(alpha: 0.76);
    final lit = hole;
    if (lit == null) {
      canvas.drawRect(Offset.zero & size, scrim);
      return;
    }
    // A target on the screen edge, like the nav bar, would otherwise push half
    // of the frame out of view.
    final window = RRect.fromRectAndRadius(
      lit.inflate(_margin).intersect((Offset.zero & size).deflate(_stroke)),
      const Radius.circular(AppDecorations.radius),
    );
    canvas
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addRRect(window),
        scrim,
      )
      ..drawRRect(
        window,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..color = AppColors.primarySoft,
      );
  }

  @override
  bool shouldRepaint(TourSpotlightPainter oldDelegate) =>
      oldDelegate.hole != hole;
}

class _CardSlot extends StatelessWidget {
  const new({required this.hole, required this.child});

  static const double _gap = 16;

  // Below this the card is unreadable, so it may cover part of the target.
  static const double _roomNeeded = 240;

  final Rect? hole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final lit = hole;
        final under = lit == null || lit.center.dy < height / 2;
        var top = inset.top + _gap;
        var bottom = inset.bottom + _gap;
        if (lit != null) {
          final fitted = under ? lit.bottom + _gap : height - lit.top + _gap;
          if (height - fitted - (under ? bottom : top) >= _roomNeeded) {
            under ? top = fitted : bottom = fitted;
          }
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(_gap, top, _gap, bottom),
          child: Align(
            alignment: under ? Alignment.bottomCenter : Alignment.topCenter,
            child: child,
          ),
        );
      },
    );
  }
}
