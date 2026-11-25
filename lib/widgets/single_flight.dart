import 'package:flutter/material.dart';

/// Runs one [action] at a time: while it is in flight the builder receives a
/// null `run` callback, so a second tap cannot send the request again.
class SingleFlight extends StatefulWidget {
  const new({
    required this.action,
    required this.builder,
    super.key,
    this.confirm,
  });

  final Future<void> Function() action;
  final Widget Function(BuildContext context, VoidCallback? run) builder;

  /// Asked before [action]; false drops the tap.
  final Future<bool> Function()? confirm;

  @override
  State<SingleFlight> createState() => _SingleFlightState();
}

class _SingleFlightState extends State<SingleFlight> {
  // Locked from the tap, busy only once the action starts: a spinner behind an
  // open question would suggest the request is already on its way.
  bool _locked = false;
  bool _busy = false;

  Future<void> _run() async {
    // Two taps can land in one frame, before the disabled state is painted.
    if (_locked) return;
    _locked = true;
    try {
      final approved = await widget.confirm?.call() ?? true;
      if (!approved || !mounted) return;
      setState(() => _busy = true);
      await widget.action();
    } finally {
      _locked = false;
      if (mounted && _busy) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _busy ? null : _run);
}
