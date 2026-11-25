import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher_partner.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/partner_map_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_sections.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class PartnerList extends StatelessWidget {
  const new({required this.partners, super.key});

  final List<VoucherPartner> partners;

  @override
  Widget build(BuildContext context) {
    return VoucherSection(
      title: tr('Lokasi mitra', 'Partner places'),
      child: partners.isEmpty
          ? Text(
              tr(
                'Lokasi mitra belum tersedia.',
                'Partner places are not listed yet.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: [
                for (final partner in partners) ...[
                  _PartnerTile(partner: partner, all: partners),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const new({required this.partner, required this.all});

  final VoucherPartner partner;
  final List<VoucherPartner> all;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PartnerFacts(partner: partner),
          TextButton.icon(
            onPressed: () => PartnerMapPage.open(context, all, focus: partner),
            icon: HugeIcon(
              icon: AppIcons.location,
              color: context.palette.accent,
              size: 18,
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            label: Text(tr('Lihat peta', 'View map')),
          ),
        ],
      ),
    );
  }
}

class _PartnerFacts extends StatelessWidget {
  const new({required this.partner});

  final VoucherPartner partner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(partner.name, style: textTheme.titleMedium),
        if (partner.isSample) const SampleDataBadge(),
        const SizedBox(height: 4),
        Text(partner.address, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(partner.hoursLabel, style: textTheme.labelMedium),
      ],
    );
  }
}

/// Keeps a placeholder outlet from reading as a signed partnership.
class SampleDataBadge extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.palette.goldSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tr('Data contoh', 'Sample data'),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.palette.goldText),
      ),
    );
  }
}
