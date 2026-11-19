import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class PaymentMethodsSection extends StatelessWidget {
  const new({
    required this.balanceRupiah,
    required this.gopayConnected,
    required this.onConnectGoPay,
    super.key,
  });

  static const double cardHeight = 144;
  static const double _gap = 12;

  final int balanceRupiah;
  final bool gopayConnected;
  final VoidCallback onConnectGoPay;

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
        SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              Expanded(
                child: _PaymentCard(
                  icon: hugeIcon(HugeIcons.strokeRoundedWallet01),
                  title: tr('Saldo', 'Balance'),
                  footer: _BalanceText(balanceRupiah: balanceRupiah),
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
  const new({required this.balanceRupiah});

  final int balanceRupiah;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        'Rp ${PointsHeader.formatNumber(balanceRupiah)}',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _GoPayStatus extends StatelessWidget {
  const new({required this.connected, required this.onConnect});

  final bool connected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          connected
              ? tr('Terhubung', 'Connected')
              : tr('Belum terhubung', 'Not connected'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (connected)
          hugeIcon(HugeIcons.strokeRoundedTick02)(
            color: context.palette.success,
            size: 24,
          )
        else
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: onConnect,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const StadiumBorder(),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(tr('Hubungkan', 'Connect')),
              ),
            ),
          ),
      ],
    );
  }
}
