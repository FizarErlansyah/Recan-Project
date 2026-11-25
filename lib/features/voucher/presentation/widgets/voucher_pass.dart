import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// What the cashier looks at: the code while the voucher is usable, a stamp
/// once it is not.
class VoucherPass extends StatelessWidget {
  const new({required this.owned, required this.status, super.key});

  final OwnedVoucher owned;
  final VoucherStatus status;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card(context),
      child: AnimatedSwitcher(
        duration: still ? Duration.zero : const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: status == VoucherStatus.active
            ? _UsableCode(key: const ValueKey('code'), owned: owned)
            : _Stamp(owned: owned, status: status),
      ),
    );
  }
}

class _UsableCode extends StatelessWidget {
  const new({required this.owned, super.key});

  final OwnedVoucher owned;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: owned.reference));
    if (!context.mounted) return;
    AppSnackBar.show(context, tr('Kode disalin', 'Code copied'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QrTile(data: owned.reference),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _copy(context),
          child: Text(
            owned.reference,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: context.palette.accent, letterSpacing: 2),
          ),
        ),
        _ExpiryLine(owned: owned),
      ],
    );
  }
}

class _QrTile extends StatelessWidget {
  const new({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    // Scanners need dark on light, whatever the theme.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDecorations.controlRadius),
      ),
      child: QrImageView(data: data, size: 180, padding: EdgeInsets.zero),
    );
  }
}

class _ExpiryLine extends StatelessWidget {
  const new({required this.owned});

  final OwnedVoucher owned;

  @override
  Widget build(BuildContext context) {
    final end = owned.expiresAt;
    if (end == null) return const SizedBox.shrink();
    final days = owned.daysLeft(DateTime.now()) ?? 0;
    return Text(
      tr(
        'Berlaku sampai ${IndonesianDate.date(end)} · sisa $days hari',
        'Valid until ${IndonesianDate.date(end)} · $days days left',
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _Stamp extends StatelessWidget {
  const new({required this.owned, required this.status})
    : super(key: const ValueKey('voucher-stamp'));

  final OwnedVoucher owned;
  final VoucherStatus status;

  String get _when {
    final at = status == VoucherStatus.used ? owned.usedAt : owned.expiresAt;
    if (at == null) return owned.reference;
    return '${owned.reference} · ${IndonesianDate.dateTime(at)}';
  }

  @override
  Widget build(BuildContext context) {
    final color = status == VoucherStatus.used
        ? context.palette.success
        : context.palette.danger;

    return Column(
      children: [
        _StampMark(label: status.label, color: color),
        const SizedBox(height: 16),
        Text(
          _when,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StampMark extends StatelessWidget {
  const new({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(AppDecorations.controlRadius),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: color, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
