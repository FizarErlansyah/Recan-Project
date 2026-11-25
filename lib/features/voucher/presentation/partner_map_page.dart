import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher_partner.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';

/// Every outlet of a voucher on one map, opened on the tapped one.
class PartnerMapPage extends StatefulWidget {
  const new({required this.partners, required this.focus, super.key});

  static void open(
    BuildContext context,
    List<VoucherPartner> partners, {
    required VoucherPartner focus,
  }) {
    Navigator.of(context).push(
      RecanPageRoute<void>(
        page: PartnerMapPage(partners: partners, focus: focus),
      ),
    );
  }

  final List<VoucherPartner> partners;
  final VoucherPartner focus;

  @override
  State<PartnerMapPage> createState() => _PartnerMapPageState();
}

class _PartnerMapPageState extends State<PartnerMapPage> {
  late VoucherPartner _selected = widget.focus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Peta Mitra', 'Partner Map'))),
      body: _PartnerMap(
        partners: widget.partners,
        selected: _selected,
        onSelected: (partner) => setState(() => _selected = partner),
      ),
      bottomNavigationBar: _SelectedPartner(partner: _selected),
    );
  }
}

class _PartnerMap extends StatelessWidget {
  const new({
    required this.partners,
    required this.selected,
    required this.onSelected,
  });

  static const double _zoom = 16;
  static const String _tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgentPackage = 'id.recan.app';

  final List<VoucherPartner> partners;
  final VoucherPartner selected;
  final ValueChanged<VoucherPartner> onSelected;

  Marker _marker(VoucherPartner partner) {
    final active = identical(partner, selected);
    final size = active ? 48.0 : 36.0;
    return Marker(
      point: partner.position,
      width: size,
      height: size,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => onSelected(partner),
        child: HugeIcon(
          icon: AppIcons.location,
          size: size,
          color: active ? AppColors.danger : AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: selected.position, initialZoom: _zoom),
      children: [
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: _userAgentPackage,
        ),
        MarkerLayer(
          markers: [for (final partner in partners) _marker(partner)],
        ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }
}

class _SelectedPartner extends StatelessWidget {
  const new({required this.partner});

  final VoucherPartner partner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(partner.name, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(partner.address, style: textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(partner.hoursLabel, style: textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
