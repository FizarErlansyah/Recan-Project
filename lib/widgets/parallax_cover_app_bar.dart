import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/circle_icon_button.dart';

class ParallaxCoverAppBar extends StatelessWidget {
  const new({
    required this.expandedHeight,
    required this.cover,
    required this.title,
    super.key,
  });

  static const double _leadingWidth = 72;

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
      backgroundColor: AppColors.scrim,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: _leadingWidth,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: CircleIconButton(
            icon: materialIcon(Icons.arrow_back_rounded),
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

          return Stack(
            fit: StackFit.expand,
            children: [
              FlexibleSpaceBar(background: RepaintBoundary(child: cover)),
              IgnorePointer(
                child: ColoredBox(
                  color: AppColors.scrim.withValues(alpha: collapse),
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
          );
        },
      ),
    );
  }
}
