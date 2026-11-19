import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/circle_icon_button.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class ParallaxCoverAppBar extends StatelessWidget {
  const new({
    required this.expandedHeight,
    required this.cover,
    required this.title,
    super.key,
  });

  static const double _leadingWidth = 72;
  // Past this point the bar is mostly emerald, so the clock needs light icons.
  static const double _lightIconsFrom = 0.6;

  final double expandedHeight;
  final Widget cover;
  final String title;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final collapseRange = expandedHeight - kToolbarHeight;
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: _leadingWidth,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: CircleIconButton(
            icon: hugeIcon(AppIcons.back),
            tooltip: tr('Kembali', 'Back'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapse =
              ((expandedHeight + topInset - constraints.maxHeight) /
                      collapseRange)
                  .clamp(0.0, 1.0);

          return StatusBarIcons(
            light: context.isDark || collapse > _lightIconsFrom,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlexibleSpaceBar(background: RepaintBoundary(child: cover)),
                IgnorePointer(
                  child: ColoredBox(
                    color: AppColors.primary.withValues(alpha: collapse),
                  ),
                ),
                Positioned(
                  left: _leadingWidth,
                  right: 16,
                  bottom: 0,
                  height: kToolbarHeight,
                  child: Opacity(
                    opacity: collapse,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
