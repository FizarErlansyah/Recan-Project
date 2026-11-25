import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/demo/presentation/demo_tools_sheet.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/info_section_card.dart';
import 'package:mobile_apps_recan/widgets/metallic_card.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';
import 'package:mobile_apps_recan/widgets/settings_sheets.dart';
import 'package:mobile_apps_recan/widgets/team_member_tile.dart';

class AboutRecanPage extends StatelessWidget {
  const new({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(FadePageRoute<void>(page: const AboutRecanPage()));

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Tentang ReCan', 'About ReCan'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + bottomInset),
        children: const [
          _HeroCard(),
          SizedBox(height: 16),
          _ProblemCard(),
          SizedBox(height: 16),
          _VisionCard(),
          SizedBox(height: 16),
          _PillarsCard(),
          SizedBox(height: 16),
          _TeamCard(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MetallicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ReCanLogo(size: 88),
          const SizedBox(height: 16),
          Text(
            'ReCan',
            style: textTheme.headlineMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Setor kaleng, kumpulkan poin, ciptakan dampak.',
              'Drop cans, collect points, create impact.',
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primarySoft),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onLongPress: DemoToolsSheet.isAvailable
                ? () => DemoToolsSheet.show(context)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tr(
                  'Versi ${SettingsSheets.appVersion} '
                      '(build ${SettingsSheets.appBuild})',
                  'Version ${SettingsSheets.appVersion} '
                      '(build ${SettingsSheets.appBuild})',
                ),
                style: textTheme.labelMedium?.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InfoSectionCard(
      icon: AppIcons.warning,
      title: tr('Masalah Limbah Kaleng', 'The Can Waste Problem'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.palette.dangerSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '80 – 200',
                  style: textTheme.headlineMedium?.copyWith(
                    color: context.palette.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr(
                      'tahun waktu yang dibutuhkan satu kaleng untuk terurai secara alami.',
                      'years for a single can to decompose naturally.',
                    ),
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr(
              'Kaleng minuman yang dibuang sembarangan menumpuk di tanah dan '
                  'saluran air selama puluhan hingga ratusan tahun. Padahal '
                  'aluminium dapat didaur ulang berkali-kali tanpa kehilangan '
                  'kualitasnya dan menghemat energi hingga 95% dibanding '
                  'produksi baru.',
              'Carelessly discarded drink cans pile up in soil and waterways '
                  'for decades to centuries. Yet aluminum can be recycled '
                  'again and again without losing quality, saving up to 95% '
                  'of the energy needed to make new metal.',
            ),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              'Berdasarkan data SIPSN 2025, komposisi sampah nasional '
                  'didominasi oleh Sisa Makanan (40,24%), disusul Plastik '
                  '(20,21%), Kayu/Ranting (12,96%), Kertas/Karton (10,74%), '
                  'Lainnya (6,94%), Logam (3,02%), dan Kaca (2,27%). '
                  'Meskipun logam (termasuk kaleng) hanya 3,02%, kaleng '
                  'membutuhkan waktu 80 hingga 200 tahun untuk terurai '
                  'secara alami dan karatnya dapat mencemari tanah.',
              'According to 2025 SIPSN data, national waste composition is '
                  'dominated by food waste (40.24%), followed by plastic '
                  '(20.21%), wood/twigs (12.96%), paper/cardboard (10.74%), '
                  'other (6.94%), metal (3.02%), and glass (2.27%). Even '
                  'though metal (including cans) is only 3.02%, a can still '
                  'takes 80 to 200 years to decompose naturally, and its '
                  'rust can contaminate the soil.',
            ),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InfoSectionCard(
      icon: AppIcons.autorenew,
      title: tr('Visi Ekonomi Sirkular', 'Circular Economy Vision'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              'ReCan mengubah kaleng bekas menjadi nilai baru: poin, saldo '
                  'e-wallet, dan produk kriya upcycling. Setiap kaleng kembali '
                  'ke siklus produksi, bukan ke tempat pembuangan.',
              'ReCan turns used cans into new value: points, e-wallet '
                  'balance, and upcycled craft products. Every can returns to '
                  'the production cycle instead of the landfill.',
            ),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SdgChip(
                label: tr(
                  'SDG 11 · Kota & Komunitas Berkelanjutan',
                  'SDG 11 · Sustainable Cities & Communities',
                ),
              ),
              _SdgChip(
                label: tr(
                  'SDG 12 · Konsumsi & Produksi Bertanggung Jawab',
                  'SDG 12 · Responsible Consumption & Production',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SdgChip extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.palette.successSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: context.palette.accent),
      ),
    );
  }
}

class _PillarsCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: AppIcons.collaboration,
      title: tr('3 Pilar Kolaborasi', '3 Pillars of Collaboration'),
      subtitle: tr('Lintas disiplin ilmu UPJ', 'Across UPJ disciplines'),
      child: Column(
        children: [
          _PillarRow(
            icon: AppIcons.smartphone,
            title: tr('Sistem Informasi', 'Information Systems'),
            description: tr(
              'Aplikasi mobile dan gamifikasi poin, misi, serta tier member.',
              'Mobile app and gamification of points, missions, and member '
                  'tiers.',
            ),
          ),
          const SizedBox(height: 16),
          _PillarRow(
            icon: AppIcons.architecture,
            title: tr('Arsitektur', 'Architecture'),
            description: tr(
              'Desain Modular Drop Station yang mudah dipasang di ruang publik.',
              'Modular Drop Station design that is easy to install in public '
                  'spaces.',
            ),
          ),
          const SizedBox(height: 16),
          _PillarRow(
            icon: AppIcons.design,
            title: tr('DKV', 'Visual Communication Design'),
            description: tr(
              'Identitas visual ReCan dan kriya upcycling dari kaleng bekas.',
              'ReCan visual identity and upcycled crafts made from used cans.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconGlyph icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: HugeIcon(icon: icon, color: AppColors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      color: context.palette.border.withValues(alpha: 0.6),
      height: 16,
      thickness: 0.5,
    );

    return InfoSectionCard(
      icon: AppIcons.team,
      title: tr('Tim Pengembang Proyek', 'Project Development Team'),
      subtitle: tr(
        'Kelompok 8 - Fakultas Teknologi dan Desain UPJ',
        'Group 8 - Faculty of Technology and Design UPJ',
      ),
      child: Column(
        children: [
          TeamMemberTile(
            name: 'Rayhan Christian Wewengkang',
            role: tr('Ketua', 'Team Leader'),
            highlighted: true,
          ),
          divider,
          TeamMemberTile(
            name: 'Fizar Erlansyah',
            role: tr('Anggota', 'Member'),
          ),
          divider,
          TeamMemberTile(
            name: 'Darrel Musyaffa Reyhan',
            role: tr('Anggota', 'Member'),
          ),
          divider,
          TeamMemberTile(
            name: 'Nailah Tsabita Alhadi',
            role: tr('Anggota', 'Member'),
          ),
          divider,
          TeamMemberTile(name: 'Shaina Zafira', role: tr('Anggota', 'Member')),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.palette.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TeamMemberTile(
              name: 'Ibu Safitri Jaya, S.Kom., M.T.I.',
              role: tr('Dosen Pengampu', 'Supervising Lecturer'),
              initials: 'SJ',
              highlighted: true,
            ),
          ),
        ],
      ),
    );
  }
}
