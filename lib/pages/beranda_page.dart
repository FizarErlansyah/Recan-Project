import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/home/presentation/home_insights_section.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/ai_chat_page.dart';
import 'package:mobile_apps_recan/pages/article_detail_page.dart';
import 'package:mobile_apps_recan/pages/drop_station_map_page.dart';
import 'package:mobile_apps_recan/pages/edukasi_page.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_apps_recan/services/dashboard_service.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/async_view.dart';
import 'package:mobile_apps_recan/widgets/carbon_analytics_section.dart';
import 'package:mobile_apps_recan/widgets/category_menu.dart';
import 'package:mobile_apps_recan/widgets/dashboard_skeleton.dart';
import 'package:mobile_apps_recan/widgets/education_card.dart';
import 'package:mobile_apps_recan/widgets/home_hero_header.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/motion/staggered_entrance.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/promo_banner_carousel.dart';
import 'package:mobile_apps_recan/widgets/section_header.dart';
import 'package:mobile_apps_recan/widgets/station_tracking_section.dart';

class BerandaPage extends StatefulWidget {
  const new({
    required this.onLogout,
    required this.onSelectTab,
    required this.onScan,
    super.key,
  });

  final VoidCallback onLogout;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onScan;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // A pull-to-refresh has to reach the sections that load on their own too.
  final ValueNotifier<int> _pulls = ValueNotifier(0);
  late final Listenable _insightsRefresh = Listenable.merge([
    DataRefresh.revision,
    _pulls,
  ]);

  @override
  void dispose() {
    _pulls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<DashboardData>(
      loader: DashboardService.fetch,
      loading: const DashboardSkeleton(),
      onUnauthorized: widget.onLogout,
      refreshOn: DataRefresh.revision,
      builder: (context, data, reload) => _Content(
        data: data,
        onRefresh: () {
          _pulls.value++;
          return reload();
        },
        insightsRefresh: _insightsRefresh,
        onSelectTab: widget.onSelectTab,
        onLogout: widget.onLogout,
        onScan: widget.onScan,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const new({
    required this.data,
    required this.onRefresh,
    required this.insightsRefresh,
    required this.onSelectTab,
    required this.onLogout,
    required this.onScan,
  });

  final DashboardData data;
  final Future<void> Function() onRefresh;
  final Listenable insightsRefresh;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onLogout;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.palette.accent,
      backgroundColor: context.palette.surface,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 104),
        children: [
          HomeHeroHeader(
            user: data.user,
            cansDeposited: data.user.totalCans,
            onAskAi: () => AiChatPage.open(context),
            onScan: onScan,
            onOpenProfile: () => onSelectTab(HomeNavigation.profileTab),
          ),
          const SizedBox(height: 12),
          StaggeredEntrance(
            index: 2,
            child: CategoryMenu(
              entries: [
                CategoryMenuEntry(
                  icon: hugeIcon(HugeIcons.strokeRoundedGift),
                  label: tr('Tukar Poin', 'Redeem'),
                  onTap: () => onSelectTab(1),
                ),
                CategoryMenuEntry(
                  icon: hugeIcon(HugeIcons.strokeRoundedAward01),
                  label: tr('Misi & Hadiah', 'Quests'),
                  onTap: () => QuestPage.open(context, onLogout: onLogout),
                ),
                CategoryMenuEntry(
                  icon: hugeIcon(HugeIcons.strokeRoundedLocation01),
                  label: tr('Drop Station', 'Stations'),
                  onTap: () =>
                      DropStationMapPage.open(context, onLogout: onLogout),
                ),
                CategoryMenuEntry(
                  icon: hugeIcon(HugeIcons.strokeRoundedBookOpen01),
                  label: tr('Edukasi', 'Learn'),
                  onTap: () => EdukasiPage.open(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HomeInsightsSection(
            refreshOn: insightsRefresh,
            onUnauthorized: onLogout,
            onScan: onScan,
            onOpenQuests: () => QuestPage.open(context, onLogout: onLogout),
            onSeeAllActivity: () => onSelectTab(HomeNavigation.activityTab),
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
                icon: hugeIcon(HugeIcons.strokeRoundedAirplane01),
                colors: const [AppColors.primary, AppColors.primaryDark],
                onTap: () => onSelectTab(1),
              ),
              PromoBanner(
                title: tr('Bonus Poin Akhir Pekan!', 'Weekend Bonus Points!'),
                subtitle: tr(
                  'Setor kaleng sekarang dan rasakan bedanya',
                  'Drop cans now and feel the difference',
                ),
                icon: hugeIcon(HugeIcons.strokeRoundedGift),
                colors: const [AppColors.slateDeep, AppColors.primaryDeep],
                onTap: () =>
                    Navigator.of(context)
                        .push(RecanPageRoute<void>(page: const ScanQrPage())),
              ),
              PromoBanner(
                title: tr('Kampanye SDG 11 & 12', 'SDG 11 & 12 Campaign'),
                subtitle: tr(
                  'Kota berkelanjutan, konsumsi bertanggung jawab',
                  'Sustainable cities, responsible consumption',
                ),
                icon: hugeIcon(HugeIcons.strokeRoundedGlobe02),
                colors: const [AppColors.primaryDark, AppColors.primaryLight],
                onTap: () => EdukasiPage.open(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StationTrackingSection(
            stations: data.dropStations,
            onLogout: onLogout,
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
          const SizedBox(height: 24),
          CarbonAnalyticsSection(onUnauthorized: onLogout),
          const SizedBox(height: 24),
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
