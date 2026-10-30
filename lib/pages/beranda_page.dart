import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/ai_chat_page.dart';
import 'package:mobile_apps_recan/pages/article_detail_page.dart';
import 'package:mobile_apps_recan/pages/drop_station_map_page.dart';
import 'package:mobile_apps_recan/pages/edukasi_page.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_apps_recan/services/dashboard_service.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/services/gamification_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/ai_chat_fab.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/carbon_analytics_section.dart';
import 'package:mobile_apps_recan/widgets/circle_icon_button.dart';
import 'package:mobile_apps_recan/widgets/daily_checkin_section.dart';
import 'package:mobile_apps_recan/widgets/daily_quest_section.dart';
import 'package:mobile_apps_recan/widgets/dashboard_skeleton.dart';
import 'package:mobile_apps_recan/widgets/drop_station_card.dart';
import 'package:mobile_apps_recan/widgets/education_card.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/impact_section.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/promo_banner_carousel.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';

class BerandaPage extends StatelessWidget {
  const new({required this.onLogout, required this.onSelectTab, super.key});

  final VoidCallback onLogout;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AsyncView<DashboardData>(
          loader: DashboardService.fetch,
          loading: const DashboardSkeleton(),
          onUnauthorized: onLogout,
          refreshOn: DataRefresh.revision,
          builder: (context, data, reload) => _Content(
            data: data,
            onRefresh: reload,
            onSelectTab: onSelectTab,
            onLogout: onLogout,
          ),
        ),
        Positioned(
          right: 24,
          bottom: MediaQuery.paddingOf(context).bottom + 16,
          child: AiChatFab(onTap: () => AiChatPage.open(context)),
        ),
      ],
    );
  }
}

class _Content extends StatefulWidget {
  const new({
    required this.data,
    required this.onRefresh,
    required this.onSelectTab,
    required this.onLogout,
  });

  final DashboardData data;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onLogout;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late Future<GamificationData> _gamification = _fetchGamification();
  GamificationData? _latestGamification;

  DashboardData get data => widget.data;
  ValueChanged<int> get onSelectTab => widget.onSelectTab;
  VoidCallback get onLogout => widget.onLogout;

  @override
  void initState() {
    super.initState();
    DataRefresh.revision.addListener(_reloadGamification);
  }

  @override
  void dispose() {
    DataRefresh.revision.removeListener(_reloadGamification);
    super.dispose();
  }

  Future<GamificationData> _fetchGamification() {
    _latestGamification = GamificationService.current;
    return GamificationService.fetch();
  }

  void _reloadGamification() {
    if (!mounted) return;
    setState(() {
      _gamification = _fetchGamification();
    });
  }

  Future<void> _refresh() {
    _reloadGamification();
    return widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 104),
        children: [
          PointsHeader(
            user: data.user,
            trailing: CircleIconButton(
              icon: Icons.notifications_outlined,
              tooltip: tr('Notifikasi', 'Notifications'),
              onTap: () => AppSnackBar.show(
                context,
                tr('Belum ada notifikasi baru', 'No new notifications'),
              ),
            ),
            onRedeem: () => onSelectTab(1),
            onScan: () =>
                Navigator.of(context)
                    .push(FadePageRoute<void>(page: const ScanQrPage())),
          ),
          const SizedBox(height: 24),
          PromoBannerCarousel(
            banners: [
              PromoBanner(
                title: tr(
                  'Tukar Kaleng Jadi Miniatur F1 & Jet!',
                  'Turn Cans Into F1 & Jet Miniatures!',
                ),
                subtitle: tr(
                  'Kumpulkan poin, tukar kriya impianmu',
                  'Collect points, redeem your dream craft',
                ),
                icon: Icons.flight_rounded,
                colors: const [AppColors.primary, AppColors.primaryDark],
                foreground: AppColors.white,
                onTap: () => onSelectTab(1),
              ),
              PromoBanner(
                title: tr('Bonus Poin Akhir Pekan!', 'Weekend Bonus Points!'),
                subtitle: tr(
                  'Setor kaleng sekarang dan rasakan bedanya',
                  'Drop cans now and feel the difference',
                ),
                icon: Icons.bolt_rounded,
                colors: const [AppColors.sand, AppColors.clay],
                foreground: AppColors.textPrimary,
                onTap: () =>
                    Navigator.of(context)
                        .push(FadePageRoute<void>(page: const ScanQrPage())),
              ),
              PromoBanner(
                title: tr(
                  'Kampanye SDG 11 & 12 UPJ',
                  'UPJ SDG 11 & 12 Campaign',
                ),
                subtitle: tr(
                  'Kampus berkelanjutan, konsumsi bertanggung jawab',
                  'Sustainable campus, responsible consumption',
                ),
                icon: Icons.public_rounded,
                colors: const [AppColors.primaryDark, AppColors.sage],
                foreground: AppColors.white,
                onTap: () => EdukasiPage.open(context),
              ),
              PromoBanner(
                title: tr(
                  'Tukar Poin Jadi Saldo E-Wallet',
                  'Turn Points Into E-Wallet Balance',
                ),
                subtitle: tr(
                  'GoPay, OVO, dan DANA mulai Rp 20.000',
                  'GoPay, OVO, and DANA from Rp 20,000',
                ),
                icon: Icons.account_balance_wallet_rounded,
                colors: const [AppColors.primaryDark, AppColors.sage],
                foreground: AppColors.white,
                onTap: () => onSelectTab(1),
              ),
              PromoBanner(
                title: tr('Tantangan Bebas Emisi', 'Zero-Emission Challenge'),
                subtitle: tr(
                  'Setor tiap hari, hemat karbon, raih Eco-Hero',
                  'Drop daily, save carbon, become an Eco-Hero',
                ),
                icon: Icons.eco_rounded,
                colors: const [AppColors.clayDark, AppColors.clay],
                foreground: AppColors.white,
                onTap: () => onSelectTab(3),
              ),
            ],
          ),
          DailyCheckInSection(
            future: _gamification,
            initialData: _latestGamification,
          ),
          const SizedBox(height: 24),
          DailyQuestSection(
            future: _gamification,
            initialData: _latestGamification,
            onRetry: _reloadGamification,
            onUnauthorized: onLogout,
          ),
          const SizedBox(height: 24),
          ImpactSection(stats: ImpactStats.dummy, userName: data.user.name),
          const SizedBox(height: 24),
          CarbonAnalyticsSection(onUnauthorized: onLogout),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Drop Station',
            subtitle: tr(
              'Titik pembuangan kaleng terdekat',
              'Nearest can drop-off points',
            ),
            actionLabel: tr('Lihat Semua', 'See All'),
            onAction: () =>
                DropStationMapPage.open(context, onLogout: onLogout),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (final station in data.dropStations) ...[
                  DropStationCard(station: station),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: tr('Katalog Daur Ulang', 'Recycling Catalog'),
            subtitle: tr(
              'Kriya dari kaleng, tukar dengan poinmu',
              'Crafts made from cans, redeem with your points',
            ),
            actionLabel: tr('Lihat Semua', 'See All'),
            onAction: () => onSelectTab(1),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: ProductCard.heightOf(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: data.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => ProductCard(
                product: data.products[i],
                onTap: () => ProductDetailPage.open(context, data.products[i]),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SectionHeader(
            title: tr('Edukasi ReCan', 'ReCan Education'),
            subtitle: tr(
              'Kenali dampak daur ulang',
              'Discover the impact of recycling',
            ),
            actionLabel: tr('Lihat Semua', 'See All'),
            onAction: () => EdukasiPage.open(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (final article in EducationService.featured) ...[
                  EducationCard(
                    article: article,
                    onTap: () => ArticleDetailPage.open(context, article),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
