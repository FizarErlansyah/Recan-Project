import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  const new({
    required this.text,
    required this.style,
    super.key,
    this.onTick,
    this.onDone,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback? onTick;
  final VoidCallback? onDone;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  static const Duration _interval = Duration(milliseconds: 18);
  static const int _runesPerTick = 2;

  late final List<int> _runes = widget.text.runes.toList();
  Timer? _timer;
  int _visibleCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visibleCount >= _runes.length) return;
    if (!MediaQuery.disableAnimationsOf(context)) {
      _timer ??= Timer.periodic(_interval, (_) => _advance());
      return;
    }
    _timer?.cancel();
    _visibleCount = _runes.length;
    // The owner usually rebuilds in answer, which it may not do mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    final next = (_visibleCount + _runesPerTick).clamp(0, _runes.length);
    setState(() {
      _visibleCount = next;
    });
    widget.onTick?.call();
    if (next >= _runes.length) {
      _timer?.cancel();
      widget.onDone?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: 0, child: Text(widget.text, style: widget.style)),
        Text(
          String.fromCharCodes(_runes.take(_visibleCount)),
          style: widget.style,
        ),
      ],
    );
  }
}
