import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/simulated_badge.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/animated_check.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const new({required this.productName, required this.receipt, super.key});

  static void show(
    BuildContext context, {
    required String productName,
    required PurchaseReceipt receipt,
    bool replaceCurrent = false,
  }) {
    final route = RecanPageRoute<void>(
      page: CheckoutSuccessPage(productName: productName, receipt: receipt),
    );
    final navigator = Navigator.of(context);
    if (replaceCurrent) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  final String productName;
  final PurchaseReceipt receipt;

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

  Future<void> _copyReference() async {
    final reference = widget.receipt.reference;
    await Clipboard.setData(ClipboardData(text: reference));
    if (!mounted) return;
    unawaited(HapticFeedback.lightImpact());
    AppSnackBar.show(
      context,
      tr(
        'Kode transaksi $reference disalin',
        'Transaction code $reference copied',
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
        backgroundColor: context.palette.background,
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
                        receipt: widget.receipt,
                        redeemedAt: _redeemedAt,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButtons(
                  onBackToHome: _backToHome,
                  onCopyCode: () => unawaited(_copyReference()),
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
    required this.receipt,
    required this.redeemedAt,
  });

  final String productName;
  final PurchaseReceipt receipt;
  final DateTime redeemedAt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reference = receipt.reference;
    final simulated = receipt.simulated;
    final details = [
      (tr('Produk', 'Product'), productName),
      ...paymentRows(receipt),
      (tr('Tanggal', 'Date'), IndonesianDate.dateTime(redeemedAt)),
      (tr('ID Transaksi', 'Transaction ID'), reference),
    ];

    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(context),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const AnimatedCheck(),
          const SizedBox(height: 16),
          Text(
            simulated
                ? tr('Pesanan Dicatat!', 'Order Recorded!')
                : tr('Penukaran Berhasil!', 'Redemption Successful!'),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            simulated
                ? tr(
                    'Pembayaran Rupiah masih simulasi',
                    'The rupiah payment is simulated',
                  )
                : tr(
                    'Salin kode transaksi sebagai bukti',
                    'Copy the transaction code as proof',
                  ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (simulated) const SimulatedBadge() else const _StatusPill(),
          const SizedBox(height: 24),
          for (final (label, value) in details) ...[
            _DetailRow(label: label, value: value),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          const _DashedDivider(),
          const SizedBox(height: 24),
          // Scanners need dark modules on a light plate, so the code keeps a
          // white background even when the receipt card is dark.
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QrImageView(
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
        color: context.palette.successSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tr('Berhasil', 'Success'),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: context.palette.success),
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
              SizedBox(
                width: 4,
                height: 1.5,
                child: ColoredBox(color: context.palette.border),
              ),
          ],
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const new({required this.onBackToHome, required this.onCopyCode});

  final VoidCallback onBackToHome;
  final VoidCallback onCopyCode;

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
            onPressed: onCopyCode,
            icon: HugeIcon(
              icon: AppIcons.copy,
              color: context.palette.accent,
              size: 20,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: context.palette.tint.withValues(alpha: 0.35),
              side: BorderSide(color: context.palette.tint, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              tr('Salin Kode Transaksi', 'Copy Transaction Code'),
              style: textTheme.labelLarge?.copyWith(
                color: context.palette.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
