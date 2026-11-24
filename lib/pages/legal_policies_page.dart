import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/info_section_card.dart';
import 'package:mobile_apps_recan/widgets/segmented_pills.dart';

class LegalPoliciesPage extends StatelessWidget {
  const new({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(FadePageRoute<void>(page: const LegalPoliciesPage()));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('Legal & Kebijakan', 'Legal & Policies')),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            SegmentedTabBar(
              labels: [
                tr('Syarat & Ketentuan', 'Terms of Service'),
                tr('Kebijakan Privasi', 'Privacy Policy'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PolicyList(sections: _termsSections),
                  _PolicyList(sections: _privacySections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<_PolicySection> get _termsSections => [
    _PolicySection(
      icon: AppIcons.recycle,
      title: tr('Aturan Pemilahan Kaleng', 'Can Sorting Rules'),
      points: [
        tr(
          'Hanya kaleng minuman aluminium yang diterima. Kaleng baja, botol '
              'plastik, dan sampah lain akan ditolak.',
          'Only aluminum drink cans are accepted. Steel cans, plastic '
              'bottles, and other waste will be rejected.',
        ),
        tr(
          'Kosongkan dan bilas kaleng dari sisa cairan sebelum disetor.',
          'Empty and rinse cans of any leftover liquid before dropping them.',
        ),
        tr(
          'Pipihkan kaleng bila memungkinkan agar kapasitas Drop Station '
              'hemat.',
          'Flatten cans when possible to save Drop Station capacity.',
        ),
        tr(
          'Dilarang memasukkan benda berbahaya, benda tajam, atau bahan '
              'mudah terbakar ke dalam Drop Station.',
          'Do not insert hazardous items, sharp objects, or flammable '
              'materials into a Drop Station.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.coins,
      title: tr('Validitas Poin', 'Point Validity'),
      points: [
        tr(
          'Poin diberikan 25 poin untuk setiap kaleng yang berhasil '
              'terverifikasi di Drop Station.',
          'Points are awarded at 25 points for every can verified at a '
              'Drop Station.',
        ),
        tr(
          'Poin hanya berasal dari setoran kaleng, misi, dan check-in harian '
              'yang sah.',
          'Points only come from valid can drops, missions, and daily '
              'check-ins.',
        ),
        tr(
          'Poin tidak dapat dipindahtangankan, dijual, atau diuangkan di luar '
              'katalog ReCan.',
          'Points cannot be transferred, sold, or cashed out outside the '
              'ReCan catalog.',
        ),
        tr(
          'Penukaran yang telah berhasil tidak dapat dibatalkan atau '
              'dikembalikan menjadi poin.',
          'Successful redemptions cannot be cancelled or converted back '
              'into points.',
        ),
        tr(
          'Poin yang diperoleh dengan cara curang, seperti manipulasi QR atau '
              'setoran palsu, dapat dibatalkan.',
          'Points earned through fraud, such as QR manipulation or fake '
              'drops, may be revoked.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.medal,
      title: tr('Tier, Misi & Hadiah', 'Tiers, Missions & Rewards'),
      points: [
        tr(
          'Tier member ditentukan dari total poin dan dapat berubah sesuai '
              'ketentuan program.',
          'Member tiers are determined by total points and may change '
              'according to program terms.',
        ),
        tr(
          'Hadiah misi harus diklaim setelah target tercapai dan mengikuti '
              'periode misi yang berlaku.',
          'Mission rewards must be claimed after the target is reached and '
              'follow the active mission period.',
        ),
        tr(
          'Ketersediaan produk kriya dan voucher bergantung pada stok dan '
              'dapat berubah tanpa pemberitahuan.',
          'Craft product and voucher availability depends on stock and may '
              'change without notice.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.legal,
      title: tr('Ketentuan Umum', 'General Terms'),
      points: [
        tr(
          'Dengan menggunakan ReCan, kamu menyetujui seluruh syarat dan '
              'ketentuan ini.',
          'By using ReCan, you agree to all of these terms and conditions.',
        ),
        tr(
          'Tim ReCan berhak menangguhkan akun yang melanggar ketentuan.',
          'The ReCan team may suspend accounts that violate these terms.',
        ),
        tr(
          'Ketentuan dapat diperbarui sewaktu-waktu dan akan diumumkan '
              'melalui aplikasi.',
          'These terms may be updated at any time and will be announced '
              'through the app.',
        ),
      ],
    ),
  ];

  static List<_PolicySection> get _privacySections => [
    _PolicySection(
      icon: AppIcons.sharedData,
      title: tr('Data yang Kami Kumpulkan', 'Data We Collect'),
      points: [
        tr(
          'Data akun: nama, email, dan nomor telepon yang kamu daftarkan.',
          'Account data: the name, email, and phone number you register.',
        ),
        tr(
          'Data aktivitas: riwayat setoran kaleng, poin, misi, dan penukaran.',
          'Activity data: can drop history, points, missions, and '
              'redemptions.',
        ),
        tr(
          'Data perangkat: izin kamera hanya digunakan untuk memindai QR Code '
              'di Drop Station.',
          'Device data: camera permission is only used to scan the QR Code '
              'on a Drop Station.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.accountSettings,
      title: tr('Penggunaan Data', 'How We Use Data'),
      points: [
        tr(
          'Data digunakan semata-mata untuk menjalankan layanan ReCan, '
              'seperti perhitungan poin, tier, dan dampak karbon.',
          'Data is used solely to run the ReCan service, such as point, '
              'tier, and carbon impact calculations.',
        ),
        tr(
          'Statistik dampak lingkungan kampus ditampilkan secara agregat '
              'tanpa membuka identitas pribadi.',
          'Campus environmental impact statistics are shown in aggregate '
              'without revealing personal identity.',
        ),
        tr(
          'Kami tidak menjual data pribadimu kepada pihak ketiga.',
          'We do not sell your personal data to third parties.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.security,
      title: tr('Keamanan Data', 'Data Security'),
      points: [
        tr(
          'Data akun dilindungi dengan praktik keamanan yang wajar dan akses '
              'terbatas bagi tim pengembang.',
          'Account data is protected with reasonable security practices and '
              'limited access for the development team.',
        ),
        tr(
          'Jaga kerahasiaan kata sandi dan jangan bagikan akunmu kepada '
              'orang lain.',
          'Keep your password confidential and do not share your account '
              'with others.',
        ),
        tr(
          'Segera hubungi Pusat Bantuan bila kamu menduga akunmu diakses '
              'tanpa izin.',
          'Contact the Help Center right away if you suspect your account '
              'was accessed without permission.',
        ),
      ],
    ),
    _PolicySection(
      icon: AppIcons.privacy,
      title: tr('Hak Pengguna', 'Your Rights'),
      points: [
        tr(
          'Kamu dapat memperbarui data profil kapan saja melalui Edit Profil.',
          'You can update your profile data at any time through Edit '
              'Profile.',
        ),
        tr(
          'Kamu dapat meminta penghapusan akun dan data melalui Pusat '
              'Bantuan.',
          'You can request deletion of your account and data through the '
              'Help Center.',
        ),
        tr(
          'Kebijakan ini dapat diperbarui dan perubahan penting akan '
              'diinformasikan di aplikasi.',
          'This policy may be updated and important changes will be '
              'communicated in the app.',
        ),
      ],
    ),
  ];
}

class _PolicySection {
  const new({required this.icon, required this.title, required this.points});

  final IconGlyph icon;
  final String title;
  final List<String> points;
}

class _PolicyList extends StatelessWidget {
  const new({required this.sections});

  final List<_PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + bottomInset),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final section = sections[index];
        return InfoSectionCard(
          icon: section.icon,
          title: section.title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < section.points.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _PolicyPoint(text: section.points[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PolicyPoint extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: textTheme.bodyMedium)),
      ],
    );
  }
}
