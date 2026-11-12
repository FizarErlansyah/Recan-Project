import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/animated_check.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const new({
    required this.productName,
    required this.totalPoints,
    required this.reference,
    super.key,
  });

  static void show(
    BuildContext context, {
    required String productName,
    required int totalPoints,
    required String reference,
    bool replaceCurrent = false,
  }) {
    final route = FadePageRoute<void>(
      page: CheckoutSuccessPage(
        productName: productName,
        totalPoints: totalPoints,
        reference: reference,
      ),
    );
    final navigator = Navigator.of(context);
    if (replaceCurrent) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  final String productName;
  final int totalPoints;
  final String reference;

  @override
  State<CheckoutSuccessPage> createState() => _CheckoutSuccessPageState();
}

class _CheckoutSuccessPageState extends State<CheckoutSuccessPage> {
  late final DateTime _redeemedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(HapticFeedback.mediumImpact());
  }

  void _saveReceipt() {
    unawaited(HapticFeedback.lightImpact());
    AppSnackBar.show(
      context,
      tr(
        'Struk berhasil disimpan ke perangkat',
        'Receipt saved to your device',
      ),
    );
  }

  void _backToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _ReceiptPaper(
                        productName: widget.productName,
                        totalPoints: widget.totalPoints,
                        redeemedAt: _redeemedAt,
                        reference: widget.reference,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButtons(
                  onBackToHome: _backToHome,
                  onSaveReceipt: _saveReceipt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptPaper extends StatelessWidget {
  const new({
    required this.productName,
    required this.totalPoints,
    required this.redeemedAt,
    required this.reference,
  });

  final String productName;
  final int totalPoints;
  final DateTime redeemedAt;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const AnimatedCheck(),
          const SizedBox(height: 16),
          Text(
            tr('Penukaran Berhasil!', 'Redemption Successful!'),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            tr('Simpan struk ini sebagai bukti', 'Keep this receipt as proof'),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const _StatusPill(),
          const SizedBox(height: 24),
          _DetailRow(label: tr('Produk', 'Product'), value: productName),
          const SizedBox(height: 12),
          _DetailRow(
            label: tr('Poin Dipotong', 'Points Deducted'),
            value: tr(
              '-${PointsHeader.formatNumber(totalPoints)} Poin',
              '-${PointsHeader.formatNumber(totalPoints)} Points',
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: tr('Tanggal', 'Date'),
            value: IndonesianDate.dateTime(redeemedAt),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: tr('ID Transaksi', 'Transaction ID'),
            value: reference,
          ),
          const SizedBox(height: 16),
          const _DashedDivider(),
          const SizedBox(height: 24),
          QrImageView(
            data: reference,
            size: 150,
            padding: EdgeInsets.zero,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.primary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(reference, style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tr('Berhasil', 'Success'),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.success),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < count; i++)
              const SizedBox(
                width: 4,
                height: 1.5,
                child: ColoredBox(color: AppColors.border),
              ),
          ],
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const new({required this.onBackToHome, required this.onSaveReceipt});

  final VoidCallback onBackToHome;
  final VoidCallback onSaveReceipt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onBackToHome,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              tr('Kembali ke Beranda', 'Back to Home'),
              style: textTheme.labelLarge?.copyWith(color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSaveReceipt,
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primarySoft.withValues(alpha: 0.35),
              side: const BorderSide(color: AppColors.primarySoft, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              tr('Simpan Struk', 'Save Receipt'),
              style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
