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
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) => _advance());
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
