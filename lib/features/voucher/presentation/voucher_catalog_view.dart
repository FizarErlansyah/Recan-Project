import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/voucher/data/voucher_service.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/my_vouchers_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_detail_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_ticket_card.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';

typedef _Offer = ({ProfileData profile, List<Voucher> vouchers});

class VoucherCatalogView extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  static Future<_Offer> _load() async {
    final profile = ProfileService.fetchProfile();
    final vouchers = VoucherService.fetch();
    // Not `(a, b).wait`: it wraps a failure in ParallelWaitError, which hides
    // the message and the expired session from AsyncView.
    await Future.wait<void>([profile, vouchers]);
    return (profile: await profile, vouchers: await vouchers);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_Offer>(
      loader: _load,
      loading: const CatalogSkeleton(),
      onUnauthorized: onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, offer, _) {
        if (offer.vouchers.isEmpty) {
          return EmptyState(
            icon: hugeIcon(HugeIcons.strokeRoundedTicket01),
            title: tr('Belum ada voucher', 'No vouchers yet'),
            message: tr(
              'Voucher mitra akan segera tersedia.',
              'Partner vouchers will be available soon.',
            ),
          );
        }
        return _OfferList(offer: offer, onLogout: onLogout);
      },
    );
  }
}

class _OfferList extends StatelessWidget {
  const new({required this.offer, required this.onLogout});

  final _Offer offer;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final points = offer.profile.points;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        _WalletShortcut(
          count: offer.profile.activeVouchers,
          onTap: () => MyVouchersPage.open(context, onLogout: onLogout),
        ),
        const SizedBox(height: 16),
        for (final voucher in offer.vouchers) ...[
          VoucherTicketCard(
            key: ValueKey(voucher.id),
            voucher: voucher,
            affordable: points >= voucher.pointsCost,
            onTap: () => VoucherDetailPage.open(
              context,
              voucher: voucher,
              balance: points,
              onLogout: onLogout,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _WalletShortcut extends StatelessWidget {
  const new({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.tint,
      borderRadius: BorderRadius.circular(AppDecorations.radius),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: HugeIcon(icon: AppIcons.gift, color: context.palette.accent),
        title: Text(
          tr('Voucher Saya', 'My Vouchers'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          tr('$count voucher aktif', '$count active vouchers'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: HugeIcon(
          icon: AppIcons.chevronRight,
          color: context.palette.accent,
          size: 20,
        ),
      ),
    );
  }
}
