import 'dart:async';

import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Streams changes of the signed-in user's profile and transactions, plus the
/// station counters, into [DataRefresh]. Screens already reload on that
/// notifier, so a balance or tier changed on the server shows up without a
/// pull-to-refresh. Row Level Security still applies to what is delivered.
class SupabaseRealtime {
  new(this._client);

  // A deposit touches profile, transaction and station in one go; waiting a
  // moment turns those three events into a single reload.
  static const Duration _settle = Duration(milliseconds: 400);

  final SupabaseClient _client;
  RealtimeChannel? _channel;
  String? _userId;
  Timer? _debounce;

  void start(String userId) {
    if (_userId == userId && _channel != null) return;
    unawaited(stop());
    _userId = userId;

    PostgresChangeFilter ownRows(String column) => PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: column,
      value: userId,
    );

    _channel = _client
        .channel('recan-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: ownRows('id'),
          callback: (_) => _notify(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: ownRows('user_id'),
          callback: (_) => _notify(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'drop_stations',
          callback: (_) => _notify(),
        )
        .subscribe();
  }

  Future<void> stop() async {
    _debounce?.cancel();
    _userId = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) await _client.removeChannel(channel);
  }

  void _notify() {
    _debounce?.cancel();
    _debounce = Timer(_settle, DataRefresh.notifyChanged);
  }
}
