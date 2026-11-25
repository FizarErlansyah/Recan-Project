import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/single_flight.dart';

class PaymentMethodsSection extends StatelessWidget {
  const new({
    required this.points,
    required this.gopayConnected,
    required this.onConnectGoPay,
    super.key,
  });

  static const double _gap = 12;

  final int points;
  final bool gopayConnected;

  /// Completes when the server has answered; the button waits for it.
  final Future<void> Function() onConnectGoPay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Metode Pembayaran', 'Payment Method'),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        // Both cards take the height of the fuller one, and no more.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PaymentCard(
                  icon: hugeIcon(HugeIcons.strokeRoundedWallet01),
                  title: tr('Saldo Poin', 'Points'),
                  footer: _BalanceText(points: points),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _PaymentCard(
                  icon: hugeIcon(HugeIcons.strokeRoundedSmartPhone01),
                  title: 'GoPay',
                  footer: _GoPayStatus(
                    connected: gopayConnected,
                    onConnect: onConnectGoPay,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const new({required this.icon, required this.title, required this.footer});

  final AppIconBuilder icon;
  final String title;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PaymentCardTitle(icon: icon, title: title),
            const SizedBox(height: 12),
            footer,
          ],
        ),
      ),
    );
  }
}

class _PaymentCardTitle extends StatelessWidget {
  const new({required this.icon, required this.title});

  final AppIconBuilder icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.palette.tint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon(color: context.palette.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _BalanceText extends StatelessWidget {
  const new({required this.points});

  // Points are worth different rupiah amounts per catalog, so a single rupiah
  // figure here would be wrong for one of them.
  final int points;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        formatPoints(points),
        // One line, or the intrinsic height reserves a second one.
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _GoPayStatus extends StatelessWidget {
  const new({required this.connected, required this.onConnect});

  final bool connected;
  final Future<void> Function() onConnect;

  @override
  Widget build(BuildContext context) {
    if (connected) return const _Connected();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tr('Belum terhubung', 'Not connected'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        _ConnectButton(onConnect: onConnect),
      ],
    );
  }
}

class _Connected extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final color = context.palette.success;

    return Row(
      children: [
        SizedBox.square(
          key: const ValueKey('gopay-tick'),
          dimension: 20,
          child: hugeIcon(HugeIcons.strokeRoundedCheckmarkCircle02)(
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            tr('Terhubung', 'Connected'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const new({required this.onConnect});

  final Future<void> Function() onConnect;

  @override
  Widget build(BuildContext context) {
    return SingleFlight(
      action: onConnect,
      builder: (context, run) => FilledButton(
        key: const ValueKey('gopay-connect'),
        onPressed: run,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
        ),
        child: _ConnectLabel(busy: run == null),
      ),
    );
  }
}

class _ConnectLabel extends StatelessWidget {
  const new({required this.busy});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.palette.textSecondary,
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(tr('Hubungkan', 'Connect')),
    );
  }
}
