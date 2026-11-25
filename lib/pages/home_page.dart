import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/features/tour/data/tour_store.dart';
import 'package:mobile_apps_recan/features/tour/presentation/coach_mark_overlay.dart';
import 'package:mobile_apps_recan/features/tour/presentation/tour_anchors.dart';
import 'package:mobile_apps_recan/pages/aktivitas_page.dart';
import 'package:mobile_apps_recan/pages/beranda_page.dart';
import 'package:mobile_apps_recan/pages/katalog_page.dart';
import 'package:mobile_apps_recan/pages/profil_page.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';
import 'package:mobile_apps_recan/widgets/tab_slot.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TourAnchors _anchors = TourAnchors();
  String? _userId;
  bool _touring = false;

  List<MainNavItem> get _items => [
    MainNavItem(
      icon: materialIcon(Icons.home_outlined),
      selectedIcon: materialIcon(Icons.home_rounded),
      label: tr('Beranda', 'Home'),
    ),
    MainNavItem(
      icon: materialIcon(Icons.shopping_cart_outlined),
      selectedIcon: materialIcon(Icons.shopping_cart_rounded),
      label: tr('Katalog', 'Catalog'),
    ),
    MainNavItem(
      anchor: _anchors.activityTab,
      icon: materialIcon(Icons.receipt_long_outlined),
      selectedIcon: materialIcon(Icons.receipt_long_rounded),
      label: tr('Aktivitas', 'Activity'),
    ),
    MainNavItem(
      anchor: _anchors.profileTab,
      icon: materialIcon(Icons.person_outline_rounded),
      selectedIcon: materialIcon(Icons.person_rounded),
      label: tr('Profil', 'Profile'),
    ),
  ];

  bool _scanOpen = false;

  // Two quick taps must not stack two cameras.
  Future<void> _openScan() async {
    if (_scanOpen) return;
    _scanOpen = true;
    await Navigator.of(context)
        .push(RecanPageRoute<void>(page: const ScanQrPage()));
    _scanOpen = false;
  }

  int _currentIndex = 0;
  final Set<int> _visited = {0};

  @override
  void initState() {
    super.initState();
    HomeNavigation.requestedTab.addListener(_handleTabRequest);
    HomeNavigation.tourRequests.addListener(_replayTour);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_warmTabs()));
  }

  /// Loads the other tabs early, so opening one later never shows a skeleton.
  /// Building them during the entrance would stall the splash morph.
  Future<void> _warmTabs() async {
    await _routeSettled();
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _visited.add(i);
      }
    });
  }

  @override
  void dispose() {
    HomeNavigation.requestedTab.removeListener(_handleTabRequest);
    HomeNavigation.tourRequests.removeListener(_replayTour);
    super.dispose();
  }

  void _handleTabRequest() {
    final requested = HomeNavigation.requestedTab.value;
    if (requested == null) return;
    HomeNavigation.requestedTab.value = null;
    _selectTab(requested);
  }

  /// Shows the tour to someone who has not seen it on this device.
  Future<void> _offerTour(String userId) async {
    _userId = userId;
    if (await TourStore.current.isDone(userId)) return;
    await _routeSettled();
    // Someone who already moved on gets it on the next visit instead.
    if (!mounted || _currentIndex != 0) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    setState(() => _touring = true);
  }

  /// Waits out the transition that brought this page in.
  Future<void> _routeSettled() async {
    if (!mounted) return;
    final entrance = ModalRoute.of(context)?.animation;
    if (entrance == null || entrance.isCompleted) return;
    final done = Completer<void>();
    void listen(AnimationStatus status) {
      if (status.isCompleted && !done.isCompleted) done.complete();
    }

    entrance.addStatusListener(listen);
    await done.future;
    entrance.removeStatusListener(listen);
  }

  void _replayTour() {
    _selectTab(0);
    setState(() => _touring = true);
  }

  void _endTour() {
    final page = _anchors.balance.currentContext;
    if (page != null) Scrollable.maybeOf(page)?.position.jumpTo(0);
    setState(() => _touring = false);
    final userId = _userId;
    if (userId != null) unawaited(TourStore.current.markDone(userId));
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
          tourAnchors: _anchors,
          onReady: (userId) => unawaited(_offerTour(userId)),
        );
      case 1:
        return KatalogPage(onLogout: _logout);
      case 2:
        return AktivitasPage(onLogout: _logout);
      default:
        return ProfilPage(onLogout: _logout);
    }
  }

  // Tabs stay alive once built, so scroll position, loaded data and carousel
  // state survive a tab switch. A hidden slot goes offstage, so only the open
  // tab is painted or hit.
  Widget _buildTabs() {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _items.length; i++)
          TabSlot(
            active: i == _currentIndex,
            side: (i - _currentIndex).sign,
            child: _visited.contains(i)
                ? _buildTab(i)
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildShell() => Scaffold(
    extendBody: true,
    body: _buildTabs(),
    bottomNavigationBar: MainNavBar(
      items: _items,
      currentIndex: _currentIndex,
      onTap: _selectTab,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MockStore.isEnglish,
      builder: (context, _, _) => StatusBarIcons(
        light: context.isDark || _touring,
        // Back closes the tour before it can leave the app.
        child: PopScope(
          canPop: !_touring,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _endTour();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildShell(),
              if (_touring)
                CoachMarkOverlay(anchors: _anchors, onDone: _endTour),
            ],
          ),
        ),
      ),
    );
  }
}
