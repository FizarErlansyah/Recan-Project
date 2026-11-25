import 'package:mobile_apps_recan/utils/localization.dart';

/// The parts of the app the tour points at, in the order it visits them.
enum TourTarget { balance, redeem, missions, stations, education, tabs }

class TourStep {
  const new({
    required this.target,
    required this.titleId,
    required this.titleEn,
    required this.bodyId,
    required this.bodyEn,
  });

  final TourTarget target;
  final String titleId;
  final String titleEn;
  final String bodyId;
  final String bodyEn;

  String get title => tr(titleId, titleEn);
  String get body => tr(bodyId, bodyEn);

  static const List<TourStep> home = [
    TourStep(
      target: TourTarget.balance,
      titleId: 'Setor kaleng, dapat poin',
      titleEn: 'Drop cans, earn points',
      bodyId:
          'Saldo poinmu ada di sini. Tekan Pindai, arahkan ke QR di Drop '
          'Station, lalu setor kalengmu.',
      bodyEn:
          'Your points balance lives here. Tap Scan, point at the QR on a '
          'Drop Station, then drop your cans.',
    ),
    TourStep(
      target: TourTarget.redeem,
      titleId: 'Tukar Poin',
      titleEn: 'Redeem points',
      bodyId:
          'Tukar poin dengan kriya dari kaleng, saldo e-wallet, atau voucher '
          'mitra.',
      bodyEn:
          'Turn points into can crafts, e-wallet balance or partner vouchers.',
    ),
    TourStep(
      target: TourTarget.missions,
      titleId: 'Misi dan hadiah',
      titleEn: 'Missions and rewards',
      bodyId: 'Klaim hadiah harian dan selesaikan misi untuk poin tambahan.',
      bodyEn: 'Claim the daily reward and finish missions for extra points.',
    ),
    TourStep(
      target: TourTarget.stations,
      titleId: 'Drop Station',
      titleEn: 'Drop Stations',
      bodyId:
          'Cari titik setor terdekat dan cek kapasitasnya sebelum berangkat.',
      bodyEn:
          'Find the nearest drop point and check its capacity before you go.',
    ),
    TourStep(
      target: TourTarget.education,
      titleId: 'Edukasi',
      titleEn: 'Learn',
      bodyId: 'Baca artikel daur ulang dan ikuti Tutorial Olah Kaleng.',
      bodyEn: 'Read recycling articles and follow the Can Craft Tutorial.',
    ),
    TourStep(
      target: TourTarget.tabs,
      titleId: 'Aktivitas dan Profil',
      titleEn: 'Activity and Profile',
      bodyId:
          'Riwayat poinmu ada di Aktivitas. Voucher, peringkat, dan '
          'pengaturan ada di Profil.',
      bodyEn:
          'Your points history is under Activity. Vouchers, rankings and '
          'settings are under Profile.',
    ),
  ];
}
