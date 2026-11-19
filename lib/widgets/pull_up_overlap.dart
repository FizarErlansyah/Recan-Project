import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays [child] out normally, reports a height shorter by [extent] and paints
/// it that far upward, so a card can overlap the section above it without
/// leaving dead space below.
///
/// `Transform.translate` alone moves the pixels but keeps the original layout
/// box, which is what produced the empty band under the balance card.
class PullUpOverlap extends SingleChildRenderObjectWidget {
  const new({required this.extent, super.key, super.child});

  final double extent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderPullUpOverlap(extent);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPullUpOverlap renderObject,
  ) {
    renderObject.extent = extent;
  }
}

class RenderPullUpOverlap extends RenderShiftedBox {
  new(this._extent) : super(null);

  double _extent;

  double get extent => _extent;

  set extent(double value) {
    if (value == _extent) return;
    _extent = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = child!.getDryLayout(constraints);
    return constraints.constrain(
      Size(childSize.width, math.max(0, childSize.height - _extent)),
    );
  }

  @override
  void performLayout() {
    final child = this.child!..layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, math.max(0, child.size.height - _extent)),
    );
    (child.parentData! as BoxParentData).offset = Offset(0, -_extent);
  }

  // The pulled-up part of the child sits outside this box; skipping the bounds
  // check keeps it tappable (same approach as RenderTransform).
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      hitTestChildren(result, position: position);
}
