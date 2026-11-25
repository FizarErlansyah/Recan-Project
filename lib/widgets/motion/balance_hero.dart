import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/widgets/brushed_metal.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_hero.dart';
import 'package:mobile_apps_recan/widgets/recan_logo.dart';

/// The metal plate that travels from the splash into the balance card.
class BalanceHero extends StatelessWidget {
  const new({required this.child, super.key});

  static const String tag = 'recan-balance-card';

  final Widget child;

  static Widget _flight(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext from,
    BuildContext to,
  ) => BalanceFlight(animation: animation);

  @override
  Widget build(BuildContext context) {
    return Hero(tag: tag, flightShuttleBuilder: _flight, child: child);
  }
}

/// What is seen in the air: bare metal that turns from the splash gunmetal into
/// the card finish while the mark dissolves. It holds no text or rows, so it
/// fits whatever size the flight gives it.
class BalanceFlight extends StatelessWidget {
  const new({required this.animation, super.key});

  /// 0 at the splash end, 1 at the card.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDecorations.heroRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const MetalSheen(
            brightness: Brightness.dark,
            child: SizedBox.expand(),
          ),
          FadeTransition(
            opacity: animation,
            child: MetalSheen(
              brightness: brightness,
              child: const SizedBox.expand(),
            ),
          ),
          _FadingMark(animation: animation),
        ],
      ),
    );
  }
}

class _FadingMark extends StatelessWidget {
  const new({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: ReverseAnimation(animation),
      child: const Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ReCanLogo(size: 96, asset: BrandHero.asset),
        ),
      ),
    );
  }
}
