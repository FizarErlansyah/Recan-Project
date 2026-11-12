import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/pages/aktivitas_page.dart';
import 'package:mobile_apps_recan/pages/beranda_page.dart';
import 'package:mobile_apps_recan/pages/katalog_page.dart';
import 'package:mobile_apps_recan/pages/profil_page.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MainNavItem> get _items => [
    MainNavItem(
      icon: hugeIcon(HugeIcons.strokeRoundedHome01),
      selectedIcon: hugeIcon(HugeIcons.strokeRoundedHome01),
      label: tr('Beranda', 'Home'),
    ),
    MainNavItem(
      icon: hugeIcon(HugeIcons.strokeRoundedShoppingCart01),
      selectedIcon: hugeIcon(HugeIcons.strokeRoundedShoppingCart01),
      label: tr('Katalog', 'Catalog'),
    ),
    MainNavItem(
      icon: hugeIcon(HugeIcons.strokeRoundedReceiptText),
      selectedIcon: hugeIcon(HugeIcons.strokeRoundedReceiptText),
      label: tr('Aktivitas', 'Activity'),
    ),
    MainNavItem(
      icon: hugeIcon(HugeIcons.strokeRoundedUser),
      selectedIcon: hugeIcon(HugeIcons.strokeRoundedUser),
      label: tr('Profil', 'Profile'),
    ),
  ];

  void _openScan() {
    Navigator.of(context).push(FadePageRoute<void>(page: const ScanQrPage()));
  }

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    HomeNavigation.requestedTab.addListener(_handleTabRequest);
  }

  @override
  void dispose() {
    HomeNavigation.requestedTab.removeListener(_handleTabRequest);
    super.dispose();
  }

  void _handleTabRequest() {
    final requested = HomeNavigation.requestedTab.value;
    if (requested == null) return;
    HomeNavigation.requestedTab.value = null;
    _selectTab(requested);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildTab() {
    switch (_currentIndex) {
      case 0:
        return BerandaPage(
          key: const ValueKey('beranda'),
          onLogout: _logout,
          onSelectTab: _selectTab,
          onScan: _openScan,
        );
      case 1:
        return KatalogPage(key: const ValueKey('katalog'), onLogout: _logout);
      case 2:
        return AktivitasPage(
          key: const ValueKey('aktivitas'),
          onLogout: _logout,
        );
      default:
        return ProfilPage(key: const ValueKey('profil'), onLogout: _logout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MockStore.isEnglish,
      builder: (context, _, _) => Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildTab(),
        ),
        bottomNavigationBar: MainNavBar(
          items: _items,
          currentIndex: _currentIndex,
          onTap: _selectTab,
        ),
      ),
    );
  }
}
