import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/logout_dialog.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/leaderboard_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/payment_methods_section.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/tier_and_voucher_section.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/my_vouchers_page.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/pages/about_recan_page.dart';
import 'package:mobile_apps_recan/pages/edit_profil_page.dart';
import 'package:mobile_apps_recan/pages/help_center_page.dart';
import 'package:mobile_apps_recan/pages/legal_policies_page.dart';
import 'package:mobile_apps_recan/pages/tier_info_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/account_header.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/page_skeletons.dart';
import 'package:mobile_apps_recan/widgets/settings_sheets.dart';
import 'package:mobile_apps_recan/widgets/settings_tile.dart';

class ProfilPage extends StatelessWidget {
  const new({required this.onLogout, super.key});

  final Future<void> Function() onLogout;

  Future<void> _connectGoPay(BuildContext context) async {
    try {
      await ProfileService.connectGoPay();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await onLogout();
      } else if (context.mounted) {
        AppSnackBar.show(context, error.message);
      }
      return;
    }
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      tr('GoPay berhasil terhubung', 'GoPay connected successfully'),
    );
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
          color: context.palette.accent,
          backgroundColor: context.palette.surface,
          onRefresh: reload,
          child: ListView(
            // The body runs under the nav bar, so the last row has to clear
            // the bar plus whatever the system gesture area adds to it.
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              AccountHeader(profile: overview.profile),
              const SizedBox(height: 24),
              TierAndVoucherSection(
                points: overview.profile.points,
                activeVouchers: overview.profile.activeVouchers,
                onTierTap: () =>
                    TierInfoPage.open(context, overview.profile.points),
                onVoucherTap: () => MyVouchersPage.open(
                  context,
                  onLogout: () => unawaited(onLogout()),
                ),
              ),
              const SizedBox(height: 32),
              PaymentMethodsSection(
                points: overview.profile.points,
                gopayConnected: overview.profile.gopayConnected,
                onConnectGoPay: () => _connectGoPay(context),
              ),
              const SizedBox(height: 32),
              LeaderboardSection(entries: overview.leaderboard),
              const SizedBox(height: 32),
              _SettingsSection(
                onEditProfile: () =>
                    EditProfilPage.open(context, overview.profile),
                onHelp: () => HelpCenterPage.open(context),
                onTour: HomeNavigation.replayTour,
                languageLabel: tr('Language | Bahasa', 'Language | English'),
                onLanguage: () => SettingsSheets.showLanguage(context),
                onAppearance: () => SettingsSheets.showAppearance(context),
                onAbout: () => AboutRecanPage.open(context),
                onLegal: () => LegalPoliciesPage.open(context),
                onLogout: () =>
                    unawaited(LogoutDialog.show(context, onConfirm: onLogout)),
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
    required this.onTour,
    required this.languageLabel,
    required this.onLanguage,
    required this.onAppearance,
    required this.onAbout,
    required this.onLegal,
    required this.onLogout,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onHelp;
  final VoidCallback onTour;
  final String languageLabel;
  final VoidCallback onLanguage;
  final VoidCallback onAppearance;
  final VoidCallback onAbout;
  final VoidCallback onLegal;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final divider = Divider(
      color: context.palette.border.withValues(alpha: 0.6),
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
                icon: AppIcons.person,
                label: tr('Edit Profil', 'Edit Profile'),
                onTap: onEditProfile,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.translate,
                label: languageLabel,
                onTap: onLanguage,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.appearance,
                label: tr('Tampilan', 'Appearance'),
                onTap: onAppearance,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.idea,
                label: tr('Lihat Panduan Aplikasi', 'View App Tour'),
                onTap: onTour,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.help,
                label: tr('Pusat Bantuan', 'Help Center'),
                onTap: onHelp,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.info,
                label: tr('Tentang', 'About'),
                onTap: onAbout,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.document,
                label: tr('Legal & Kebijakan', 'Legal & Policies'),
                onTap: onLegal,
              ),
              divider,
              SettingsTile(
                icon: AppIcons.logout,
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
