import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/activity_style.dart';

class ActivityDetailSheet extends StatelessWidget {
  const new({required this.transaction, super.key});

  static Future<void> show(
    BuildContext context,
    ActivityTransaction transaction,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ActivityDetailSheet(transaction: transaction),
    );
  }

  final ActivityTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ActivityIconBadge(transaction: transaction, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      transaction.amountLabel,
                      style: textTheme.headlineMedium?.copyWith(
                        color: transaction.amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.title,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border, height: 1),
                    _DetailRow(
                      label: tr('ID Transaksi', 'Transaction ID'),
                      value: transaction.transactionId,
                    ),
                    _DetailRow(
                      label: tr('Jenis', 'Type'),
                      value: transaction.typeLabel,
                    ),
                    _DetailRow(
                      label: tr('Waktu', 'Time'),
                      value: IndonesianDate.dateTime(transaction.timestamp),
                    ),
                    _DetailRow(
                      label: tr('Lokasi', 'Location'),
                      value: transaction.locationLabel,
                    ),
                    _DetailRow(
                      label: 'Status',
                      value: transaction.statusLabel,
                      valueColor: AppColors.success,
                    ),
                    if (transaction.isDeposit)
                      _DetailRow(
                        label: tr('Berat', 'Weight'),
                        value: tr(
                          '${(transaction.weightKg * 1000).round()} Gram',
                          '${(transaction.weightKg * 1000).round()} Grams',
                        ),
                      ),
                    const Divider(color: AppColors.border, height: 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  tr('Tutup', 'Close'),
                  style: textTheme.labelLarge?.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const new({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label, style: textTheme.bodySmall),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.titleSmall?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
