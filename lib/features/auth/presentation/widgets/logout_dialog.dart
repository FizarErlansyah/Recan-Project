import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// Confirmation that stays up, locked, while the sign-out runs.
class LogoutDialog extends StatefulWidget {
  const new({required this.onConfirm, super.key});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LogoutDialog(onConfirm: onConfirm),
    );
  }

  final Future<void> Function() onConfirm;

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onConfirm();
    // Signing out normally replaces the whole stack. Popping then would close
    // the login page, so only a dialog that is still on top closes itself.
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(
          tr('Keluar dari ReCan?', 'Sign out of ReCan?'),
          style: textTheme.titleLarge,
        ),
        content: Text(
          tr(
            'Kamu perlu masuk kembali untuk mengakses akunmu.',
            'You need to sign in again to access your account.',
          ),
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(tr('Batal', 'Cancel')),
          ),
          TextButton(
            key: const ValueKey('logout-confirm'),
            onPressed: _busy ? null : _confirm,
            style: TextButton.styleFrom(
              foregroundColor: context.palette.danger,
            ),
            child: _busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.palette.danger,
                    ),
                  )
                : Text(tr('Keluar', 'Sign Out')),
          ),
        ],
      ),
    );
  }
}
