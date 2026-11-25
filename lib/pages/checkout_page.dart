import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_channel_picker.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/payment_summary.dart';
import 'package:mobile_apps_recan/features/catalog/presentation/points_usage_card.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_amount.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/quantity_stepper.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';
import 'package:mobile_apps_recan/widgets/recan_text_field.dart';

class CheckoutPage extends StatefulWidget {
  const new({required this.product, super.key});

  static void open(BuildContext context, UpcycleProduct product) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: CheckoutPage(product: product)));
  }

  final UpcycleProduct product;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Future<ProfileData> _profile = ProfileService.fetchProfile();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Null until the buyer decides, so the default can follow the balance.
  bool? _usePoints;
  int? _requestedPoints;
  PaymentChannel _channel = PaymentChannel.qris;
  int _quantity = 1;
  bool _isSubmitting = false;
  String? _addressError;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Points are spent without asking only when they cover the whole order; a
  // partial spend is something the buyer switches on.
  bool _usesPoints(int balance) =>
      _usePoints ?? balance >= widget.product.pricePoints * _quantity;

  PaymentQuote _quoteFor(int balance) {
    final product = widget.product;
    final everything = product.pricePoints * _quantity;
    return PaymentQuote.of(
      unitPriceIdr: product.priceIdr,
      unitPricePoints: product.pricePoints,
      quantity: _quantity,
      balance: balance,
      requestedPoints: _usesPoints(balance)
          ? _requestedPoints ?? everything
          : 0,
    );
  }

  String _balanceLabel(AsyncSnapshot<ProfileData> snapshot) {
    final data = snapshot.data;
    if (data != null) {
      return tr(
        'Saldo kamu: ${formatPoints(data.points)}',
        'Your balance: ${formatPoints(data.points)}',
      );
    }
    return snapshot.hasError
        ? tr('Saldo poin tidak dapat dimuat', 'Balance could not be loaded')
        : tr('Memeriksa saldo...', 'Checking balance...');
  }

  Future<void> _confirm(PaymentQuote quote) async {
    if (_isSubmitting) return;

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() {
        _addressError = tr(
          'Alamat pengiriman wajib diisi',
          'Shipping address is required',
        );
      });
      AppSnackBar.show(context, _addressError!);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final PurchaseReceipt receipt;
    try {
      receipt = await TransactionService.redeem(
        productId: widget.product.id,
        quantity: _quantity,
        shippingAddress: address,
        pointsUsed: quote.pointsUsed,
        channel: quote.cashDue > 0 ? _channel : null,
        notes: _notesController.text.trim(),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _profile = ProfileService.fetchProfile();
      });
      AppSnackBar.show(context, error.message);
      return;
    }

    HomeNavigation.goTo(0);
    if (!mounted) return;
    CheckoutSuccessPage.show(
      context,
      replaceCurrent: true,
      productName: widget.product.name,
      receipt: receipt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileData>(
      future: _profile,
      builder: (context, snapshot) {
        final balance = snapshot.data?.points ?? 0;
        final quote = _quoteFor(balance);
        final known = snapshot.hasData || snapshot.hasError;
        final canPay = known && widget.product.stock > 0 && !_isSubmitting;

        return Scaffold(
          appBar: AppBar(title: Text(tr('Pembayaran', 'Checkout'))),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              _SectionTitle(tr('Ringkasan Pesanan', 'Order Summary')),
              _OrderSummary(
                product: widget.product,
                quantity: _quantity,
                enabled: !_isSubmitting,
                onQuantityChanged: (value) => setState(() {
                  _quantity = value;
                }),
              ),
              const SizedBox(height: 32),
              _SectionTitle(tr('Detail Pengiriman', 'Shipping Details')),
              _ShippingFields(
                address: _addressController,
                notes: _notesController,
                enabled: !_isSubmitting,
                addressError: _addressError,
                onAddressChanged: () {
                  if (_addressError == null) return;
                  setState(() => _addressError = null);
                },
              ),
              const SizedBox(height: 32),
              _SectionTitle(tr('Pembayaran', 'Payment')),
              PointsUsageCard(
                quote: quote,
                balanceLabel: _balanceLabel(snapshot),
                usePoints: _usesPoints(balance),
                enabled: !_isSubmitting,
                onToggle: (value) => setState(() => _usePoints = value),
                onPointsChanged: (value) => setState(() {
                  _usePoints = true;
                  _requestedPoints = value;
                }),
              ),
              if (quote.cashDue > 0) ...[
                const SizedBox(height: 24),
                PaymentChannelPicker(
                  selected: _channel,
                  enabled: !_isSubmitting,
                  onSelected: (value) => setState(() => _channel = value),
                ),
              ],
            ],
          ),
          bottomNavigationBar: _ConfirmBar(
            quote: quote,
            enabled: canPay,
            isSubmitting: _isSubmitting,
            onPressed: () => _confirm(quote),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _ShippingFields extends StatelessWidget {
  const new({
    required this.address,
    required this.notes,
    required this.enabled,
    required this.addressError,
    required this.onAddressChanged,
  });

  final TextEditingController address;
  final TextEditingController notes;
  final bool enabled;
  final String? addressError;
  final VoidCallback onAddressChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReCanTextField(
          controller: address,
          label: tr('Alamat Pengiriman', 'Shipping Address'),
          hint: tr(
            'Contoh: Jl. Cendrawasih No. 12, Tangerang Selatan',
            'Example: 12 Cendrawasih St., South Tangerang',
          ),
          icon: AppIcons.location,
          maxLines: 3,
          enabled: enabled,
          errorText: addressError,
          onChanged: (_) => onAddressChanged(),
        ),
        const SizedBox(height: 16),
        ReCanTextField(
          controller: notes,
          label: tr('Catatan', 'Notes'),
          hint: tr(
            'Pesan untuk penjual (opsional)',
            'Message for the seller (optional)',
          ),
          icon: AppIcons.notes,
          maxLines: 2,
          enabled: enabled,
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const new({
    required this.product,
    required this.quantity,
    required this.enabled,
    required this.onQuantityChanged,
  });

  static const double _imageSize = 64;

  final UpcycleProduct product;
  final int quantity;
  final bool enabled;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final soldOut = product.stock <= 0;

    return ReCanCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: CoverImage(
                    url: product.imageUrl,
                    seed: product.id,
                    art: ProductArt.of(product.category, product.id),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      soldOut
                          ? tr('Stok habis', 'Out of stock')
                          : tr(
                              'Sisa stok: ${product.stock}',
                              'Stock left: ${product.stock}',
                            ),
                      style: textTheme.bodySmall?.copyWith(
                        color: soldOut
                            ? context.palette.danger
                            : context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!soldOut) ...[
            const SizedBox(height: 12),
            Divider(color: context.palette.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Jumlah', 'Quantity'),
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr(
                          '${PointsHeader.formatNumber(product.pricePoints)} '
                              'Poin / item',
                          '${PointsHeader.formatNumber(product.pricePoints)} Points / '
                              'item',
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                QuantityStepper(
                  value: quantity,
                  min: 1,
                  max: product.stock,
                  enabled: enabled,
                  onChanged: onQuantityChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const new({
    required this.quote,
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final PaymentQuote quote;
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TotalRow(quote: quote),
            const SizedBox(height: 12),
            _ConfirmButton(
              label: quote.cashDue > 0
                  ? tr('Bayar (Simulasi)', 'Pay (Simulated)')
                  : tr('Tukar dengan Poin', 'Redeem with Points'),
              enabled: enabled,
              isSubmitting: isSubmitting,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const new({
    required this.label,
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const ValueKey('checkout-confirm'),
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        disabledBackgroundColor: isSubmitting
            ? context.palette.primary
            : context.palette.border,
      ),
      child: isSubmitting
          ? const _Submitting()
          : Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: enabled
                    ? context.palette.onPrimary
                    : context.palette.textSecondary,
              ),
            ),
    );
  }
}

class _Submitting extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.palette.onPrimary,
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const new({required this.quote});

  final PaymentQuote quote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            tr('Total Pembayaran', 'Total Payment'),
            style: textTheme.bodyMedium,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedAmount(
              value: quote.cashDue,
              format: formatRupiah,
              textKey: const ValueKey('checkout-total'),
              style: textTheme.titleMedium,
            ),
            if (quote.pointsUsed > 0)
              Text(
                '+ ${formatPoints(quote.pointsUsed)}',
                style: textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }
}
