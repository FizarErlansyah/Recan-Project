import 'package:flutter/material.dart';

/// Number that eases from its previous value to a new one.
///
/// With a [memoryKey] the last value survives the widget being unmounted
/// (a reload, a skeleton in between), so coming back animates from where the
/// number was instead of replaying 0 → value on every visit.
class CountUp extends StatefulWidget {
  const new({
    required this.value,
    required this.format,
    super.key,
    this.style,
    this.memoryKey,
    this.duration = const Duration(milliseconds: 600),
  });

  static final Map<String, double> _remembered = {};

  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final String? memoryKey;
  final Duration duration;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late double _from = _rememberedValue ?? 0;
  late double _to = widget.value;

  double? get _rememberedValue {
    final key = widget.memoryKey;
    return key == null ? null : CountUp._remembered[key];
  }

  double get _current => _from + (_to - _from) * _curve.value;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_remember);
    if (_from != _to) _run();
  }

  void _run() => _controller.forward(from: 0);

  @override
  void didUpdateWidget(CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _to) return;
    _from = _current;
    _to = widget.value;
    _run();
  }

  void _remember(AnimationStatus status) {
    final key = widget.memoryKey;
    if (status == AnimationStatus.completed && key != null) {
      CountUp._remembered[key] = _to;
    }
  }

  @override
  void dispose() {
    final key = widget.memoryKey;
    if (key != null) CountUp._remembered[key] = _current;
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return Text(widget.format(_to), style: widget.style);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          Text(widget.format(_current), style: widget.style),
    );
  }
}
