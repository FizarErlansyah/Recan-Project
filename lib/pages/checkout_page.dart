import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/payment_option_tile.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/quantity_stepper.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';
import 'package:mobile_apps_recan/widgets/recan_text_field.dart';

enum PaymentMethod {
  points(AppIcons.coins),
  qris(AppIcons.qr),
  gopay(AppIcons.wallet),
  bankTransfer(AppIcons.bank);

  new(this.icon);

  final IconGlyph icon;

  String get title => switch (this) {
    PaymentMethod.points => 'ReCan Points',
    PaymentMethod.qris => 'QRIS',
    PaymentMethod.gopay => 'GoPay',
    PaymentMethod.bankTransfer => tr('Transfer Bank', 'Bank Transfer'),
  };

  String get subtitle => switch (this) {
    PaymentMethod.points => tr(
      'Tukar langsung dengan poinmu',
      'Redeem directly with your points',
    ),
    PaymentMethod.qris => tr(
      'Scan & bayar dengan e-wallet apa saja',
      'Scan & pay with any e-wallet',
    ),
    PaymentMethod.gopay => tr(
      'Bayar lewat aplikasi Gojek',
      'Pay through the Gojek app',
    ),
    PaymentMethod.bankTransfer => tr(
      'Virtual account semua bank',
      'Virtual account for all banks',
    ),
  };
}

class CheckoutPage extends StatefulWidget {
  const new({required this.product, super.key});

  static void open(BuildContext context, UpcycleProduct product) {
    Navigator.of(context)
        .push(FadePageRoute<void>(page: CheckoutPage(product: product)));
  }

  final UpcycleProduct product;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final Future<ProfileData> _profile = ProfileService.fetchProfile();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  PaymentMethod? _selected;
  int _quantity = 1;
  bool _isSubmitting = false;
  String? _addressError;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalPoints => widget.product.pricePoints * _quantity;
  int get _totalRupiah => widget.product.priceIdr * _quantity;

  PaymentMethod _resolveMethod(bool affordable) {
    final chosen = _selected;
    if (chosen != null && (chosen != PaymentMethod.points || affordable)) {
      return chosen;
    }
    return affordable ? PaymentMethod.points : PaymentMethod.qris;
  }

  String _pointsHint(AsyncSnapshot<ProfileData> snapshot, bool affordable) {
    if (snapshot.connectionState != ConnectionState.done) {
      return tr('Memeriksa saldo...', 'Checking balance...');
    }
    final data = snapshot.data;
    if (data == null) {
      return tr('Saldo tidak dapat dimuat', 'Balance could not be loaded');
    }
    final balance = PointsHeader.formatNumber(data.points);
    return affordable
        ? tr('Saldo kamu: $balance poin', 'Your balance: $balance points')
        : tr(
            'Poin tidak cukup (saldo $balance poin)',
            'Not enough points (balance $balance points)',
          );
  }

  String _hintFor(
    PaymentMethod method,
    AsyncSnapshot<ProfileData> snapshot,
    bool affordable,
  ) {
    if (method == PaymentMethod.points) {
      return tr(
        '${PointsHeader.formatNumber(_totalPoints)} Poin • '
            '${_pointsHint(snapshot, affordable)}',
        '${PointsHeader.formatNumber(_totalPoints)} Points • '
            '${_pointsHint(snapshot, affordable)}',
      );
    }
    return tr('Belum tersedia', 'Not available yet');
  }

  Future<void> _confirm(PaymentMethod method) async {
    if (_isSubmitting) return;

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() {
        _addressError = tr(
          'Alamat pengiriman wajib diisi',
          'Shipping address is required',
        );
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String reference;
    try {
      reference = await TransactionService.redeem(
        productId: widget.product.id,
        quantity: _quantity,
        shippingAddress: address,
        notes: _notesController.text.trim(),
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
    HomeNavigation.goTo(0);
    if (!mounted) return;
    CheckoutSuccessPage.show(
      context,
      replaceCurrent: true,
      productName: widget.product.name,
      totalPoints: _totalPoints,
      reference: reference,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<ProfileData>(
      future: _profile,
      builder: (context, snapshot) {
        final balance = snapshot.data?.points;
        final affordable = balance != null && balance >= _totalPoints;
        final method = _resolveMethod(affordable);
        final inStock = product.stock > 0;
        final total = method == PaymentMethod.points
            ? tr(
                '${PointsHeader.formatNumber(_totalPoints)} Poin',
                '${PointsHeader.formatNumber(_totalPoints)} Points',
              )
            : 'Rp ${PointsHeader.formatNumber(_totalRupiah)}';

        return Scaffold(
          appBar: AppBar(title: Text(tr('Pembayaran', 'Checkout'))),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                tr('Ringkasan Pesanan', 'Order Summary'),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _OrderSummary(
                product: product,
                quantity: _quantity,
                enabled: !_isSubmitting,
                onQuantityChanged: (value) => setState(() {
                  _quantity = value;
                }),
              ),
              const SizedBox(height: 32),
              Text(
                tr('Detail Pengiriman', 'Shipping Details'),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ReCanTextField(
                controller: _addressController,
                label: tr(
                  'Alamat Pengiriman Kampus / Rumah',
                  'Campus / Home Shipping Address',
                ),
                hint: tr(
                  'Contoh: Gedung A Lt. 2, UPJ Bintaro',
                  'Example: Building A, 2nd Floor, UPJ Bintaro',
                ),
                icon: AppIcons.location,
                maxLines: 3,
                enabled: !_isSubmitting,
                errorText: _addressError,
                onChanged: (_) {
                  if (_addressError == null) return;
                  setState(() {
                    _addressError = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              ReCanTextField(
                controller: _notesController,
                label: tr('Catatan', 'Notes'),
                hint: tr(
                  'Pesan untuk penjual (opsional)',
                  'Message for the seller (optional)',
                ),
                icon: AppIcons.notes,
                maxLines: 2,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 32),
              Text(
                tr('Pilih Metode Pembayaran', 'Choose Payment Method'),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final option in PaymentMethod.values) ...[
                PaymentOptionTile(
                  icon: option.icon,
                  title: option.title,
                  subtitle: option.subtitle,
                  hint: _hintFor(option, snapshot, affordable),
                  selected: method == option,
                  enabled:
                      !_isSubmitting &&
                      option == PaymentMethod.points &&
                      affordable,
                  onTap: () => setState(() {
                    _selected = option;
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
          bottomNavigationBar: _ConfirmBar(
            total: total,
            enabled:
                inStock && !_isSubmitting && method == PaymentMethod.points,
            isSubmitting: _isSubmitting,
            onPressed: () => _confirm(method),
          ),
        );
      },
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
                  child: CoverImage(url: product.imageUrl, seed: product.id),
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
                            ? AppColors.danger
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!soldOut) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
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
    required this.total,
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final String total;
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('Total Pembayaran', 'Total Payment'),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      total,
                      key: ValueKey(total),
                      style: textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: enabled ? onPressed : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  disabledBackgroundColor: isSubmitting
                      ? AppColors.primary
                      : AppColors.border,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        tr('Konfirmasi Pesanan', 'Confirm Order'),
                        style: textTheme.labelLarge?.copyWith(
                          color: enabled
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
