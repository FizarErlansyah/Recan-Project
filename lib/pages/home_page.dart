import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
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
import 'package:mobile_apps_recan/widgets/tab_slot.dart';

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

  bool _loggingOut = false;

  // Several tabs can report an expired session at once; one sign-out is enough.
  Future<void> _logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    await AuthService.logout();
    if (!mounted) return;
    // Pushed pages may sit above this one, so the whole stack is dropped.
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
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
  // data and carousel state survive a tab switch. Each slot crossfades and
  // goes offstage once hidden, so only the active tab is painted or hit.
  Widget _buildTabs() {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _items.length; i++)
          TabSlot(
            active: i == _currentIndex,
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
        light: context.isDark,
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
