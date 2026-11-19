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
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

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
  final Set<int> _visited = {0};

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
      _visited.add(index);
    });
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return BerandaPage(
          onLogout: _logout,
          onSelectTab: _selectTab,
          onScan: _openScan,
        );
      case 1:
        return KatalogPage(onLogout: _logout);
      case 2:
        return AktivitasPage(onLogout: _logout);
      default:
        return ProfilPage(onLogout: _logout);
    }
  }

  // Tabs build on first visit and then stay alive, so scroll position, loaded
  // data and carousel state survive a tab switch. TickerMode stops animations
  // in the tabs that are offstage.
  Widget _buildTabs() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        for (var i = 0; i < _items.length; i++)
          TickerMode(
            enabled: i == _currentIndex,
            child: _visited.contains(i)
                ? _buildTab(i)
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MockStore.isEnglish,
      builder: (context, _, _) => StatusBarIcons(
        light: false,
        child: Scaffold(
          extendBody: true,
          body: _buildTabs(),
          bottomNavigationBar: MainNavBar(
            items: _items,
            currentIndex: _currentIndex,
            onTap: _selectTab,
          ),
        ),
      ),
    );
  }
}
