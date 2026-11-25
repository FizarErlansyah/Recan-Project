import 'package:latlong2/latlong.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

/// An outlet where a voucher can be used.
class VoucherPartner {
  const new({
    required this.name,
    required this.address,
    required this.position,
    this.opensAt,
    this.closesAt,
    this.isOpenAllDay = false,
    this.isSample = false,
  });

  /// Reads a `voucher_partners` row.
  factory fromJson(Map<String, dynamic> json) => VoucherPartner(
    name: json['name'] as String,
    address: json['address'] as String,
    position: LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
    opensAt: json['opens_at'] as String?,
    closesAt: json['closes_at'] as String?,
    isOpenAllDay: json['open_24h'] as bool? ?? false,
    isSample: json['is_sample'] as bool? ?? false,
  );

  final String name;
  final String address;
  final LatLng position;

  /// `HH:MM` or `HH:MM:SS`, Jakarta time.
  final String? opensAt;
  final String? closesAt;
  final bool isOpenAllDay;

  /// A placeholder outlet that is not a signed partner yet.
  final bool isSample;

  String get hoursLabel {
    if (isOpenAllDay) return tr('Buka 24 jam', 'Open 24 hours');
    final opens = opensAt;
    final closes = closesAt;
    if (opens == null || closes == null) {
      return tr('Jam buka belum tersedia', 'Opening hours not listed');
    }
    return '${_clock(opens)}-${_clock(closes)} WIB';
  }

  static String _clock(String time) =>
      time.substring(0, 5).replaceFirst(':', '.');
}
