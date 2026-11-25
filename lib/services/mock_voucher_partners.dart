import 'package:latlong2/latlong.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher_partner.dart';

/// Offline copy of the sample outlets seeded by
/// `supabase/migrations/20261126_voucher_partners.sql`. None is a signed partner.
abstract final class MockVoucherPartners {
  static const List<VoucherPartner> meal = [
    VoucherPartner(
      name: 'Warung Daur Rasa',
      address:
          'Area kuliner dekat Pasar Modern Bintaro, Sektor 7, Pondok Aren, '
          'Tangerang Selatan',
      position: LatLng(-6.27995, 106.71905),
      opensAt: '08:00',
      closesAt: '21:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Kedai Kopi Putar',
      address:
          'Area dekat Bintaro Plaza, Sektor 3A, Pondok Aren, '
          'Tangerang Selatan',
      position: LatLng(-6.27305, 106.74225),
      opensAt: '09:00',
      closesAt: '21:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Dapur Kaleng Hijau',
      address: 'Area dekat Stasiun Rawa Buntu, Serpong, Tangerang Selatan',
      position: LatLng(-6.31455, 106.67650),
      opensAt: '07:00',
      closesAt: '20:00',
      isSample: true,
    ),
  ];

  static const List<VoucherPartner> parking = [
    VoucherPartner(
      name: 'Parkir Motor Lingkar Ranji',
      address:
          'Area dekat Stasiun Pondok Ranji, Ciputat Timur, Tangerang Selatan',
      position: LatLng(-6.27700, 106.74440),
      opensAt: '05:00',
      closesAt: '23:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Parkir Motor Lingkar Mangu',
      address: 'Area dekat Stasiun Jurang Mangu, Ciputat, Tangerang Selatan',
      position: LatLng(-6.28890, 106.72945),
      opensAt: '05:00',
      closesAt: '23:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Parkir Motor Lingkar Taman Kota',
      address: 'Area dekat Taman Kota 1, BSD City, Serpong, Tangerang Selatan',
      position: LatLng(-6.28850, 106.67630),
      opensAt: '06:00',
      closesAt: '22:00',
      isSample: true,
    ),
  ];

  static const List<VoucherPartner> print = [
    VoucherPartner(
      name: 'Fotokopi Salin Hijau',
      address: 'Area dekat Stasiun Jurang Mangu, Ciputat, Tangerang Selatan',
      position: LatLng(-6.28830, 106.72885),
      opensAt: '08:00',
      closesAt: '20:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Cetak Putar Bintaro',
      address:
          'Area dekat Bintaro Plaza, Sektor 3A, Pondok Aren, '
          'Tangerang Selatan',
      position: LatLng(-6.27240, 106.74160),
      opensAt: '08:00',
      closesAt: '21:00',
      isSample: true,
    ),
    VoucherPartner(
      name: 'Fotokopi Rawa Lestari',
      address: 'Area dekat Stasiun Rawa Buntu, Serpong, Tangerang Selatan',
      position: LatLng(-6.31520, 106.67590),
      opensAt: '07:30',
      closesAt: '19:00',
      isSample: true,
    ),
  ];
}
