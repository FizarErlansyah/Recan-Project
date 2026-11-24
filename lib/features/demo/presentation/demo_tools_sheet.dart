import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

/// Presenter shortcut: lets a demo reach the redeem flow without depositing
/// cans first. It is reachable only by long-pressing the version chip on the
/// About page, so the first-run Zero State stays untouched on screen.
///
/// It edits the in-memory demo data, so it works only in debug builds
/// (`kDebugMode`) on the mock backend. A release build, or any build on real
/// data, must never be able to hand out fake points.
class DemoToolsSheet {
  const new _();

  static bool get isAvailable => kDebugMode && !Backend.current.isRemote;

  static Future<void> show(BuildContext context) {
    if (!isAvailable) return Future<void>.value();
    final messenger = ScaffoldMessenger.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _DemoToolsBody(
        onGrant: () {
          MockStore.grantDemoPoints();
          DataRefresh.notifyChanged();
          Navigator.of(sheetContext).pop();
          AppSnackBar.showWith(
            messenger,
            tr(
              '+${PointsHeader.formatNumber(MockStore.demoPointsGrant)} poin demo ditambahkan',
              '+${PointsHeader.formatNumber(MockStore.demoPointsGrant)} demo points added',
            ),
          );
        },
        onReset: () {
          MockStore.resetDemoState();
          DataRefresh.notifyChanged();
          Navigator.of(sheetContext).pop();
          AppSnackBar.showWith(
            messenger,
            tr('Data demo dikembalikan ke nol', 'Demo data reset to zero'),
          );
        },
      ),
    );
  }
}

class _DemoToolsBody extends StatelessWidget {
  const new({required this.onGrant, required this.onReset});

  final VoidCallback onGrant;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Alat Demo', 'Demo Tools'), style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              tr(
                'Hanya untuk presentasi. Data tidak disimpan di server.',
                'For presentations only. Nothing is saved to a server.',
              ),
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _DemoAction(
              icon: AppIcons.coins,
              label: tr(
                'Tambah +${PointsHeader.formatNumber(MockStore.demoPointsGrant)} poin',
                'Add +${PointsHeader.formatNumber(MockStore.demoPointsGrant)} points',
              ),
              onTap: onGrant,
            ),
            _DemoAction(
              icon: AppIcons.refresh,
              label: tr('Reset ke 0', 'Reset to 0'),
              onTap: onReset,
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoAction extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final IconGlyph icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 22, color: context.palette.accent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
