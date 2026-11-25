import 'package:flutter/widgets.dart';

/// Runs [action] once, after [child] has first been painted.
class OnFirstFrame extends StatefulWidget {
  const new({required this.action, required this.child, super.key});

  final VoidCallback action;
  final Widget child;

  @override
  State<OnFirstFrame> createState() => _OnFirstFrameState();
}

class _OnFirstFrameState extends State<OnFirstFrame> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.action();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
