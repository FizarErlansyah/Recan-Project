import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_amount.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// Lets the buyer choose how many points to put toward an order and shows
/// the rupiah that remains.
class PointsUsageCard extends StatelessWidget {
  const new({
    required this.quote,
    required this.balanceLabel,
    required this.usePoints,
    required this.onToggle,
    required this.onPointsChanged,
    super.key,
    this.enabled = true,
  });

  final PaymentQuote quote;
  final String balanceLabel;
  final bool usePoints;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onPointsChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final usable = enabled && quote.maxUsablePoints > 0;

    return ReCanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ToggleRow(
            balanceLabel: balanceLabel,
            value: usePoints && quote.maxUsablePoints > 0,
            onChanged: usable ? onToggle : null,
          ),
          if (usePoints && quote.maxUsablePoints > 0)
            _PointsSlider(
              quote: quote,
              onChanged: enabled ? onPointsChanged : null,
            ),
          Divider(color: context.palette.border, height: 24),
          _Breakdown(quote: quote),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const new({
    required this.balanceLabel,
    required this.value,
    required this.onChanged,
  });

  final String balanceLabel;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Gunakan Poin', 'Use Points'),
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(balanceLabel, style: textTheme.bodySmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _PointsSlider extends StatelessWidget {
  const new({required this.quote, required this.onChanged});

  final PaymentQuote quote;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final change = onChanged;

    return Column(
      children: [
        Slider(
          value: quote.pointsUsed.toDouble(),
          max: quote.maxUsablePoints.toDouble(),
          semanticFormatterCallback: (value) => formatPoints(value.round()),
          onChanged: change == null ? null : (value) => change(value.round()),
        ),
        Text(
          tr(
            'Pakai ${formatPoints(quote.pointsUsed)} dari '
                '${formatPoints(quote.maxUsablePoints)}',
            'Using ${formatPoints(quote.pointsUsed)} of '
                '${formatPoints(quote.maxUsablePoints)}',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const new({required this.quote});

  final PaymentQuote quote;

  static String _discount(int value) => '-${formatRupiah(value)}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _Line(
          label: tr('Harga Asli', 'Original Price'),
          value: quote.grossIdr,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _Line(
          label: tr('Potongan Poin', 'Points Discount'),
          value: quote.discountIdr,
          format: _discount,
          style: textTheme.bodyMedium?.copyWith(color: context.palette.success),
        ),
        const SizedBox(height: 8),
        _Line(
          label: tr('Sisa Dibayar Rupiah', 'Rupiah Left to Pay'),
          value: quote.cashDue,
          style: textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.style,
    this.format = formatRupiah,
  });

  final String label;
  final int value;
  final TextStyle? style;
  final String Function(int value) format;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        AnimatedAmount(value: value, format: format, style: style),
      ],
    );
  }
}
