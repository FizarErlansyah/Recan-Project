import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

String formatRupiah(int value) => 'Rp ${PointsHeader.formatNumber(value)}';

String formatPoints(int value) {
  final number = PointsHeader.formatNumber(value);
  return tr('$number Poin', '$number Points');
}

/// Label and value pairs describing how an order was settled, shared by the
/// receipt and the history detail so both always say the same thing.
List<(String, String)> paymentRows(PurchaseReceipt receipt) {
  final gross = receipt.grossIdr;
  final discount = receipt.discountIdr;
  final channel = receipt.channel;
  final usedPoints = receipt.pointsUsed > 0;

  return [
    (tr('Metode Pembayaran', 'Payment Method'), receipt.mode.label),
    if (gross != null)
      (tr('Harga Asli', 'Original Price'), formatRupiah(gross)),
    if (usedPoints)
      (
        tr('Poin Dipakai', 'Points Used'),
        '-${formatPoints(receipt.pointsUsed)}',
      ),
    if (discount != null && usedPoints)
      (tr('Potongan Poin', 'Points Discount'), '-${formatRupiah(discount)}'),
    if (gross != null)
      (tr('Dibayar Rupiah', 'Paid in Rupiah'), formatRupiah(receipt.cashPaid)),
    if (channel != null)
      (tr('Saluran Pembayaran', 'Payment Channel'), channel.title),
    if (receipt.simulated)
      (tr('Status Rupiah', 'Rupiah Status'), tr('Simulasi', 'Simulated')),
  ];
}
