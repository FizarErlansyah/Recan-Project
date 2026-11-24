import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/pages/drop_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/bounce_counter.dart';
import 'package:mobile_apps_recan/widgets/can_preset_chips.dart';
import 'package:mobile_apps_recan/widgets/drop_estimate_card.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class DropSessionPage extends StatefulWidget {
  const new({required this.stationName, required this.stationId, super.key});

  final String stationName;
  final int stationId;

  @override
  State<DropSessionPage> createState() => _DropSessionPageState();
}

class _DropSessionPageState extends State<DropSessionPage> {
  int _cans = 0;
  bool _collective = false;
  bool _isSubmitting = false;

  DropSessionSummary get _summary => DropSessionSummary(cans: _cans);

  void _addPreset(int amount) {
    if (amount >= CanPresetChips.collectiveAmount) _collective = true;
    _addCans(amount);
  }

  void _addCans(int amount) {
    if (_isSubmitting) return;
    setState(() {
      _cans += amount;
    });
  }

  void _insertCan() {
    unawaited(HapticFeedback.lightImpact());
    _addCans(1);
  }

  Future<void> _finish() async {
    if (_isSubmitting) return;
    if (_cans == 0) {
      AppSnackBar.show(
        context,
        tr(
          'Masukkan minimal 1 kaleng dulu.',
          'Please add at least 1 can first.',
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await TransactionService.submitDrop(
        _cans,
        stationId: widget.stationId,
        collective: _collective,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      AppSnackBar.show(context, error.message);
      return;
    }

    DataRefresh.notifyChanged();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadePageRoute<void>(
        page: DropSuccessPage(
          stationName: widget.stationName,
          summary: _summary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.scrim,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(dimension: 8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr('TERHUBUNG', 'CONNECTED'),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.stationName,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: BounceCounter(
                                    value: _cans,
                                    label: tr('Kaleng', 'Cans'),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 96,
                                color: AppColors.white.withValues(alpha: 0.16),
                              ),
                              Expanded(
                                child: Center(
                                  child: BounceCounter(
                                    value: _summary.points,
                                    label: tr('Poin', 'Points'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          DropEstimateCard(summary: _summary),
                          const SizedBox(height: 16),
                          CanPresetChips(
                            onPreset: _addPreset,
                            enabled: !_isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _insertCan,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.primarySoft,
                    side: const BorderSide(color: AppColors.primarySoft),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    tr(
                      '+ Simulasi Masukkan Kaleng',
                      '+ Simulate Inserting a Can',
                    ),
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primarySoft,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSubmitting ? null : _finish,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primarySoft,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primarySoft,
                    disabledForegroundColor: AppColors.primary,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          tr('Selesai & Tutup Sesi', 'Finish & Close Session'),
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
