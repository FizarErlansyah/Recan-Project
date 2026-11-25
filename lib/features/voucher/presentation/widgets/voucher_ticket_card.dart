import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_emblem.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_badge.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

/// A voucher on offer. It answers "where and for how long" before the tap, and
/// grows with the text instead of clipping it.
class VoucherTicketCard extends StatelessWidget {
  const new({
    required this.voucher,
    required this.affordable,
    required this.onTap,
    super.key,
  });

  final Voucher voucher;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ReCanCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: VoucherEmblem.heroTag(voucher),
            child: VoucherEmblem(voucher: voucher),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TicketBody(voucher: voucher, affordable: affordable),
          ),
          const SizedBox(width: 8),
          HugeIcon(
            icon: AppIcons.chevronRight,
            color: context.palette.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const new({required this.voucher, required this.affordable});

  final Voucher voucher;
  final bool affordable;

  String get _summary {
    final days = voucher.validityDays;
    final places = voucher.partners.length;
    if (places == 0) return tr('Berlaku $days hari', 'Valid for $days days');
    return tr(
      '$places lokasi mitra · berlaku $days hari',
      '$places partner places · valid $days days',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(voucher.title, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(_summary, style: textTheme.bodySmall),
        const SizedBox(height: 8),
        PointsBadge(points: voucher.pointsCost),
        if (!affordable) ...[
          const SizedBox(height: 4),
          Text(
            tr('Poin belum cukup', 'Not enough points yet'),
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
