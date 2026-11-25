import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/features/station/domain/scanned_station.dart';
import 'package:mobile_apps_recan/pages/drop_session_page.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';

/// Decides what a successful scan leads to.
abstract final class StationGate {
  /// Replaces the current page with a drop session, or explains why the
  /// station cannot take cans and returns false once that is dismissed.
  static Future<bool> enter(
    BuildContext context,
    ScannedStation station,
  ) async {
    if (station.acceptsDeposits) {
      Navigator.of(context).pushReplacement(
        FadePageRoute<void>(page: DropSessionPage(station: station)),
      );
      return true;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _StationBlockedDialog(station: station),
    );
    return false;
  }
}

class _StationBlockedDialog extends StatelessWidget {
  const new({required this.station});

  final ScannedStation station;

  (String, String) get _text => switch (station.effectiveStatus) {
    StationStatus.full => (
      tr('Station Penuh', 'Station Full'),
      tr(
        '${station.name} sedang menunggu pengambilan kaleng. Coba station lain.',
        '${station.name} is waiting for a pickup. Try another station.',
      ),
    ),
    StationStatus.maintenance => (
      tr('Station Dalam Perawatan', 'Station Under Maintenance'),
      tr(
        '${station.name} sedang dirawat dan belum bisa menerima kaleng.',
        '${station.name} is under maintenance and cannot take cans yet.',
      ),
    ),
    StationStatus.offline || StationStatus.available => (
      tr('Station Offline', 'Station Offline'),
      tr(
        '${station.name} sedang tidak beroperasi. Coba station lain.',
        '${station.name} is not operating. Try another station.',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (title, message) = _text;

    return AlertDialog(
      title: Text(title, style: textTheme.titleLarge),
      content: Text(message, style: textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Mengerti', 'Got It')),
        ),
      ],
    );
  }
}
