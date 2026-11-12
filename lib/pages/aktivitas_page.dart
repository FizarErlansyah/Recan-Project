import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/services/activity_service.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/activity_history_list.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/empty_state.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';

class AktivitasPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Aktivitas', 'Activity'),
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Riwayat setoran dan penukaran poin',
                    'History of deposits and point redemptions',
                  ),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AsyncView<List<ActivityTransaction>>(
              loader: ActivityService.fetch,
              loading: const ActivitySkeleton(),
              onUnauthorized: onLogout,
              refreshOn: DataRefresh.revision,
              builder: (context, transactions, reload) {
                if (transactions.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: tr('Belum ada aktivitas', 'No activity yet'),
                    message: tr(
                      'Setoran kaleng dan penukaran poinmu akan muncul di sini.',
                      'Your can deposits and point redemptions will appear here.',
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: reload,
                  child: ActivityHistoryList(transactions: transactions),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
