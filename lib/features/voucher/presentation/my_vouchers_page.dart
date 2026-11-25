import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/features/voucher/data/voucher_service.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/owned_voucher_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_emblem.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

class MyVouchersPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  static void open(BuildContext context, {required VoidCallback onLogout}) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: MyVouchersPage(onLogout: onLogout)));
  }

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: VoucherStatus.values.length,
      child: Scaffold(
        appBar: AppBar(title: Text(tr('Voucher Saya', 'My Vouchers'))),
        body: Column(
          children: [
            SegmentedTabBar(
              labels: [for (final status in VoucherStatus.values) status.label],
            ),
            const SizedBox(height: 16),
            Expanded(child: _Wallet(onLogout: onLogout)),
          ],
        ),
      ),
    );
  }
}

class _Wallet extends StatelessWidget {
  const new({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<OwnedVoucher>>(
      loader: VoucherService.owned,
      loading: const ActivitySkeleton(),
      onUnauthorized: onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, wallet, _) {
        final now = DateTime.now();
        return TabBarView(
          children: [
            for (final status in VoucherStatus.values)
              _StatusList(
                status: status,
                vouchers: [
                  for (final owned in wallet)
                    if (owned.statusAt(now) == status) owned,
                ],
              ),
          ],
        );
      },
    );
  }
}

class _StatusList extends StatelessWidget {
  const new({required this.status, required this.vouchers});

  final VoucherStatus status;
  final List<OwnedVoucher> vouchers;

  // Rows past the first screenful appear at once instead of queueing.
  static const int _staggered = 6;

  @override
  Widget build(BuildContext context) {
    if (vouchers.isEmpty) return _EmptyTab(status: status);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: vouchers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => StaggeredEntrance(
        index: index.clamp(0, _staggered),
        child: _WalletRow(owned: vouchers[index], status: status),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const new({required this.status});

  final VoucherStatus status;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (status) {
      VoucherStatus.active => (
        tr('Belum ada voucher aktif', 'No active vouchers'),
        tr(
          'Tukar poinmu di Katalog, tab Voucher.',
          'Redeem your points in the Catalog, Vouchers tab.',
        ),
      ),
      VoucherStatus.used => (
        tr('Belum ada voucher terpakai', 'No used vouchers'),
        tr(
          'Voucher yang sudah kamu pakai muncul di sini.',
          'Vouchers you have used show up here.',
        ),
      ),
      VoucherStatus.expired => (
        tr('Tidak ada voucher kedaluwarsa', 'No expired vouchers'),
        tr(
          'Pakai voucher sebelum masa berlakunya habis.',
          'Use your vouchers before they run out.',
        ),
      ),
    };

    return EmptyState(
      icon: hugeIcon(HugeIcons.strokeRoundedTicket01),
      title: title,
      message: message,
    );
  }
}

class _WalletRow extends StatelessWidget {
  const new({required this.owned, required this.status});

  final OwnedVoucher owned;
  final VoucherStatus status;

  @override
  Widget build(BuildContext context) {
    return ReCanCard(
      onTap: () => OwnedVoucherPage.open(context, owned),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VoucherEmblem(voucher: owned.voucher, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: _RowText(owned: owned, status: status),
          ),
        ],
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  const new({required this.owned, required this.status});

  final OwnedVoucher owned;
  final VoucherStatus status;

  String get _when {
    final end = owned.expiresAt;
    final used = owned.usedAt;
    return switch (status) {
      VoucherStatus.active when end != null => tr(
        'Sampai ${IndonesianDate.date(end)} · sisa '
            '${owned.daysLeft(DateTime.now())} hari',
        'Until ${IndonesianDate.date(end)} · '
            '${owned.daysLeft(DateTime.now())} days left',
      ),
      VoucherStatus.used when used != null => tr(
        'Dipakai ${IndonesianDate.dateTime(used)}',
        'Used ${IndonesianDate.dateTime(used)}',
      ),
      VoucherStatus.expired when end != null => tr(
        'Berakhir ${IndonesianDate.date(end)}',
        'Ended ${IndonesianDate.date(end)}',
      ),
      _ => IndonesianDate.dateTime(owned.redeemedAt),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(owned.voucher.title, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${tr('Kode', 'Code')} ${owned.reference}',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(_when, style: textTheme.bodySmall),
      ],
    );
  }
}
