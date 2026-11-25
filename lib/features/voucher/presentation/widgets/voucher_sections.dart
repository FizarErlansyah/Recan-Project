import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// A titled block of the voucher screens.
class VoucherSection extends StatelessWidget {
  const new({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class VoucherTerms extends StatelessWidget {
  const new({required this.terms, super.key});

  final List<String> terms;

  @override
  Widget build(BuildContext context) {
    return VoucherSection(
      title: tr('Syarat & ketentuan', 'Terms & conditions'),
      child: _NumberedCard(
        rows: terms.isEmpty
            ? [tr('Syarat belum tersedia.', 'Terms are not listed yet.')]
            : terms,
      ),
    );
  }
}

class VoucherSteps extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return VoucherSection(
      title: tr('Cara menukar', 'How to redeem'),
      child: _NumberedCard(
        rows: [
          tr(
            'Tukar poinmu. Voucher langsung masuk ke Voucher Saya.',
            'Redeem your points. The voucher lands in My Vouchers.',
          ),
          tr(
            'Datang ke salah satu lokasi mitra sebelum masa berlaku habis.',
            'Visit one of the partner places before it expires.',
          ),
          tr(
            'Tunjukkan QR atau kode ke kasir, lalu geser untuk tandai '
                'dipakai di depan kasir.',
            'Show the QR or code to the cashier, then swipe to mark it used '
                'in front of them.',
          ),
        ],
      ),
    );
  }
}

class _NumberedCard extends StatelessWidget {
  const new({required this.rows});

  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(context),
      child: Column(
        children: [
          for (final (index, row) in rows.indexed)
            _NumberedRow(number: index + 1, text: row),
        ],
      ),
    );
  }
}

class _NumberedRow extends StatelessWidget {
  const new({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: textTheme.titleSmall?.copyWith(
              color: context.palette.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
