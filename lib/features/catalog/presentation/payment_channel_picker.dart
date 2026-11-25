import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/payment_option_tile.dart';

class PaymentChannelPicker extends StatelessWidget {
  const new({
    required this.selected,
    required this.onSelected,
    super.key,
    this.enabled = true,
  });

  final PaymentChannel selected;
  final ValueChanged<PaymentChannel> onSelected;
  final bool enabled;

  static IconGlyph _iconOf(PaymentChannel channel) => switch (channel) {
    PaymentChannel.qris => AppIcons.qr,
    PaymentChannel.bankTransfer => AppIcons.bank,
    PaymentChannel.ewallet => AppIcons.wallet,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Bayar Sisa dengan', 'Pay the Rest With'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'Simulasi: belum ada uang yang ditarik.',
            'Simulation: no money is charged yet.',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        for (final channel in PaymentChannel.values) ...[
          const SizedBox(height: 12),
          PaymentOptionTile(
            icon: _iconOf(channel),
            title: channel.title,
            subtitle: channel.subtitle,
            selected: channel == selected,
            enabled: enabled,
            onTap: () => onSelected(channel),
          ),
        ],
      ],
    );
  }
}
