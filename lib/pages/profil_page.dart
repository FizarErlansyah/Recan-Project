import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/leaderboard_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/payment_methods_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/tier_and_voucher_section.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/about_recan_page.dart';
import 'package:mobile_apps_recan/pages/edit_profil_page.dart';
import 'package:mobile_apps_recan/pages/help_center_page.dart';
import 'package:mobile_apps_recan/pages/legal_policies_page.dart';
import 'package:mobile_apps_recan/pages/tier_info_page.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/account_header.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/settings_sheets.dart';
import 'package:mobile_apps_recan/widgets/settings_tile.dart';

class ProfilPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final VoidCallback onLogout;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          tr('Keluar dari ReCan?', 'Sign out of ReCan?'),
          style: Theme.of(dialogContext).textTheme.titleLarge,
        ),
        content: Text(
          tr(
            'Kamu perlu masuk kembali untuk mengakses akunmu.',
            'You need to sign in again to access your account.',
          ),
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(tr('Keluar', 'Sign Out')),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AsyncView<ProfileOverview>(
        loader: ProfileService.fetchOverview,
        loading: const ProfileSkeleton(),
        onUnauthorized: onLogout,
        refreshOn: DataRefresh.revision,
        builder: (context, overview, reload) => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: [
              AccountHeader(profile: overview.profile),
              const SizedBox(height: 24),
              TierAndVoucherSection(
                points: overview.profile.points,
                onTierTap: () =>
                    TierInfoPage.open(context, overview.profile.points),
              ),
              const SizedBox(height: 32),
              PaymentMethodsSection(
                balanceRupiah:
                    overview.profile.points * PointsHeader.rupiahPerPoint,
                gopayConnected: overview.profile.gopayConnected,
                onConnectGoPay: () {
                  unawaited(ProfileService.connectGoPay());
                  AppSnackBar.show(
                    context,
                    tr(
                      'GoPay berhasil terhubung',
                      'GoPay connected successfully',
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              LeaderboardSection(entries: overview.leaderboard),
              const SizedBox(height: 32),
              _SettingsSection(
                onEditProfile: () =>
                    EditProfilPage.open(context, overview.profile),
                onHelp: () => HelpCenterPage.open(context),
                languageLabel: tr('Language | Bahasa', 'Language | English'),
                onLanguage: () => SettingsSheets.showLanguage(context),
                onAbout: () => AboutRecanPage.open(context),
                onLegal: () => LegalPoliciesPage.open(context),
                onLogout: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const new({
    required this.onEditProfile,
    required this.onHelp,
    required this.languageLabel,
    required this.onLanguage,
    required this.onAbout,
    required this.onLegal,
    required this.onLogout,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onHelp;
  final String languageLabel;
  final VoidCallback onLanguage;
  final VoidCallback onAbout;
  final VoidCallback onLegal;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final divider = Divider(
      color: AppColors.border.withValues(alpha: 0.6),
      height: 1,
      thickness: 0.5,
      indent: 56,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('Pengaturan', 'Settings'), style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.person_outline_rounded,
                label: tr('Edit Profil', 'Edit Profile'),
                onTap: onEditProfile,
              ),
              divider,
              SettingsTile(
                icon: Icons.translate_rounded,
                label: languageLabel,
                onTap: onLanguage,
              ),
              divider,
              SettingsTile(
                icon: Icons.help_outline_rounded,
                label: tr('Pusat Bantuan', 'Help Center'),
                onTap: onHelp,
              ),
              divider,
              SettingsTile(
                icon: Icons.info_outline_rounded,
                label: tr('Tentang', 'About'),
                onTap: onAbout,
              ),
              divider,
              SettingsTile(
                icon: Icons.description_outlined,
                label: tr('Legal & Kebijakan', 'Legal & Policies'),
                onTap: onLegal,
              ),
              divider,
              SettingsTile(
                icon: Icons.logout_rounded,
                label: tr('Keluar', 'Logout'),
                onTap: onLogout,
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
