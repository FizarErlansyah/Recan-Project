import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/simulated_badge.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/widgets/activity_detail_sheet.dart';
import 'package:mobile_apps_recan/widgets/activity_style.dart';

class ActivityTile extends StatelessWidget {
  const new({required this.transaction, required this.isLast, super.key});

  static const double _iconSize = 44;

  final ActivityTransaction transaction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => ActivityDetailSheet.show(context, transaction),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    ActivityIconBadge(transaction: transaction),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.transactionId,
                            style: textTheme.labelSmall?.copyWith(
                              color: context.palette.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            IndonesianDate.dateTime(transaction.timestamp),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _AmountColumn(transaction: transaction),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: context.palette.border,
            height: 1,
            indent: 8 + _iconSize + 12,
          ),
      ],
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const new({required this.transaction});

  final ActivityTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final extra = transaction.extraAmountLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          transaction.amountLabel,
          style: textTheme.titleSmall?.copyWith(
            color: transaction.amountColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        if (extra != null) ...[
          const SizedBox(height: 4),
          Text(extra, style: textTheme.bodySmall),
        ],
        const SizedBox(height: 4),
        if (transaction.isSimulated)
          const SimulatedBadge(key: ValueKey('simulated-badge'))
        else
          Text(transaction.statusLabel, style: textTheme.bodySmall),
      ],
    );
  }
}
