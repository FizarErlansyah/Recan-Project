import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/error_state.dart';

class AsyncView<T> extends StatefulWidget {
  const new({
    required this.loader,
    required this.loading,
    required this.builder,
    required this.onUnauthorized,
    super.key,
    this.refreshOn,
  });

  final Future<T> Function() loader;
  final Widget loading;
  final Widget Function(
    BuildContext context,
    T data,
    Future<void> Function() reload,
  )
  builder;
  final VoidCallback onUnauthorized;
  final Listenable? refreshOn;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  static const Duration _crossfade = Duration(milliseconds: 180);

  late Future<T> _future = widget.loader();
  T? _latestData;
  bool _keepLatestWhileLoading = false;

  @override
  void initState() {
    super.initState();
    widget.refreshOn?.addListener(_refreshSilently);
  }

  @override
  void didUpdateWidget(covariant AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshOn == widget.refreshOn) return;
    oldWidget.refreshOn?.removeListener(_refreshSilently);
    widget.refreshOn?.addListener(_refreshSilently);
  }

  @override
  void dispose() {
    widget.refreshOn?.removeListener(_refreshSilently);
    super.dispose();
  }

  void _refreshSilently() {
    if (!mounted) return;
    setState(() {
      _keepLatestWhileLoading = _latestData != null;
      _future = widget.loader();
    });
  }

  Future<void> _reload() async {
    final next = widget.loader();
    setState(() {
      _keepLatestWhileLoading = false;
      _future = next;
    });
    try {
      await next;
    } on Object catch (_) {
      // FutureBuilder already renders the failure; swallowing here only
      // prevents an unhandled-error report for the same future.
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) => AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : _crossfade,
        child: _stateOf(context, snapshot),
      ),
    );
  }

  // Each state carries its own key so AnimatedSwitcher crossfades skeleton,
  // error and content; stale data and fresh data share one key, so a silent
  // refresh updates in place instead of flashing.
  Widget _stateOf(BuildContext context, AsyncSnapshot<T> snapshot) {
    final stale = _latestData;
    final isLoading = snapshot.connectionState != ConnectionState.done;
    final keepStale =
        _keepLatestWhileLoading &&
        stale != null &&
        (isLoading || snapshot.hasError);
    if (keepStale) {
      return KeyedSubtree(
        key: const ValueKey('data'),
        child: widget.builder(context, stale, _reload),
      );
    }

    if (isLoading) {
      return KeyedSubtree(
        key: const ValueKey('loading'),
        child: widget.loading,
      );
    }
    final error = snapshot.error;
    if (error != null) {
      final unauthorized = error is ApiException && error.unauthorized;
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: ErrorState(
          message: error is ApiException
              ? error.message
              : tr(
                  'Terjadi kesalahan tak terduga.',
                  'An unexpected error occurred.',
                ),
          actionLabel: unauthorized
              ? tr('Masuk Kembali', 'Sign In Again')
              : tr('Coba Lagi', 'Try Again'),
          onRetry: unauthorized ? widget.onUnauthorized : _reload,
        ),
      );
    }
    final data = snapshot.data as T;
    _latestData = data;
    _keepLatestWhileLoading = false;
    return KeyedSubtree(
      key: const ValueKey('data'),
      child: widget.builder(context, data, _reload),
    );
  }
}
