import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/widgets/metal_reflection.dart';

/// A polished-metal card: silver in light mode, gunmetal in dark, lit like the
/// tier card. A band of light crosses it once as it arrives, then it rests.
class BrushedMetal extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppDecorations.heroRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  static const List<Color> _light = [
    Color(0xFFFBFCFD),
    Color(0xFFDFE7ED),
    Color(0xFFF4F7F9),
    Color(0xFFD3DDE6),
  ];
  static const List<Color> _dark = [
    Color(0xFF213746),
    Color(0xFF162936),
    Color(0xFF1D3341),
    Color(0xFF12212B),
  ];

  /// The gradient stops of the metal, top left to bottom right.
  static List<Color> tones(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  /// The brightest light laid over the metal, behind the content.
  static Color glint(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.primarySoft.withValues(alpha: 0.05)
      : AppColors.white.withValues(alpha: 0.75);

  @override
  State<BrushedMetal> createState() => _BrushedMetalState();
}

class _BrushedMetalState extends State<BrushedMetal>
    with SingleTickerProviderStateMixin {
  static const Duration _arrival = Duration(milliseconds: 1500);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _arrival,
  );
  // The wait lets the card settle into place before the light crosses it.
  late final CurvedAnimation _sweep = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 1, curve: Curves.easeInOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: context.palette.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) => MetalSheen(
            brightness: brightness,
            sweep: _sweep.value,
            child: child!,
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

/// Paints the metal behind [child]. [sweep] runs from 0 to 1 as the travelling
/// light crosses; at 1 it has left the card.
class MetalSheen extends StatelessWidget {
  const new({
    required this.brightness,
    required this.child,
    super.key,
    this.sweep = 1,
  });

  final Brightness brightness;
  final double sweep;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MetalPainter(brightness: brightness, sweep: sweep),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class _MetalPainter extends CustomPainter {
  const new({required this.brightness, required this.sweep});

  final Brightness brightness;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BrushedMetal.tones(brightness),
        ).createShader(area),
    );
    _reflection().paint(canvas, size);
    if (sweep > 0 && sweep < 1) _travellingLight(canvas, size);
  }

  MetalReflectionPainter _reflection() {
    final dark = brightness == Brightness.dark;

    return MetalReflectionPainter(
      band: BrushedMetal.glint(brightness),
      // White streaks vanish on silver, so light mode draws them in shade.
      line: dark
          ? AppColors.silverLight.withValues(alpha: 0.26)
          : AppColors.silver.withValues(alpha: 0.45),
      edge: dark
          ? AppColors.primarySoft.withValues(alpha: 0.45)
          : AppColors.white,
    );
  }

  void _travellingLight(Canvas canvas, Size size) {
    final glint = BrushedMetal.glint(brightness);
    final band = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.3,
      height: size.longestSide * 2,
    );
    canvas
      ..save()
      ..translate(size.width * (-0.4 + 1.8 * sweep), size.height / 2)
      ..rotate(0.38)
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            colors: [
              glint.withValues(alpha: 0),
              glint,
              glint.withValues(alpha: 0),
            ],
          ).createShader(band),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MetalPainter oldDelegate) =>
      oldDelegate.brightness != brightness || oldDelegate.sweep != sweep;
}
