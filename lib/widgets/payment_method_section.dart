import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_shadows.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class PaymentMethodSection extends StatelessWidget {
  const new({
    required this.balanceRupiah,
    required this.gopayConnected,
    required this.onConnectGoPay,
    super.key,
  });

  static const double cardWidth = 200;
  static const double cardHeight = 136;

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
          height: cardHeight + 24,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _PaymentCard(
                icon: Icons.account_balance_wallet_rounded,
                title: tr('Saldo', 'Balance'),
                subtitle: 'Rp ${PointsHeader.formatNumber(balanceRupiah)}',
              ),
              const SizedBox(width: 16),
              _PaymentCard(
                icon: Icons.payments_rounded,
                title: 'GoPay',
                subtitle: gopayConnected
                    ? tr('Terhubung', 'Connected')
                    : tr('Belum terhubung', 'Not connected'),
                action: _ConnectButton(
                  connected: gopayConnected,
                  onPressed: onConnectGoPay,
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
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: PaymentMethodSection.cardWidth,
      height: PaymentMethodSection.cardHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: textTheme.titleMedium)),
            ],
          ),
          if (action == null)
            Text(subtitle, style: textTheme.headlineSmall)
          else
            Row(
              children: [
                Expanded(child: Text(subtitle, style: textTheme.bodySmall)),
                action!,
              ],
            ),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const new({required this.connected, required this.onPressed});

  final bool connected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: connected ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.successSoft,
          shape: const StadiumBorder(),
        ),
        child: connected
            ? const Icon(Icons.check_rounded, color: AppColors.success)
            : Text(
                tr('Hubungkan', 'Connect'),
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}
