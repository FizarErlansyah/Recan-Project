import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/voucher.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class VoucherTicketCard extends StatelessWidget {
  const new({
    required this.voucher,
    required this.affordable,
    required this.onRedeem,
    super.key,
  });

  static const double height = 136;
  static const double _stubWidth = 120;
  static const double _notchRadius = 12;

  final Voucher voucher;
  final bool affordable;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const clipper = _TicketClipper(
      stubWidth: _stubWidth,
      notchRadius: _notchRadius,
      cornerRadius: 16,
    );

    return CustomPaint(
      foregroundPainter: _TicketOutlinePainter(clipper, context.palette.border),
      child: ClipPath(
        clipper: clipper,
        child: ColoredBox(
          color: context.palette.surface,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: voucher.colors),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: voucher.icon,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                voucher.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 1,
                  height: height,
                  child: CustomPaint(
                    painter: _DashedDividerPainter(context.palette.border),
                  ),
                ),
                SizedBox(
                  width: _stubWidth - 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        PointsHeader.formatNumber(voucher.pointsCost),
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(tr('Poin', 'Points'), style: textTheme.bodySmall),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: onRedeem,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            backgroundColor: affordable
                                ? AppColors.primary
                                : context.palette.border,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            tr('Tukar', 'Redeem'),
                            style: textTheme.labelLarge?.copyWith(
                              color: affordable
                                  ? AppColors.white
                                  : context.palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketOutlinePainter extends CustomPainter {
  const new(this.clipper, this.color);

  final _TicketClipper clipper;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_TicketOutlinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.clipper.shouldReclip(clipper);
}

class _TicketClipper extends CustomClipper<Path> {
  const new({
    required this.stubWidth,
    required this.notchRadius,
    required this.cornerRadius,
  });

  final double stubWidth;
  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(cornerRadius),
        ),
      );
    final dividerX = size.width - stubWidth;
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(dividerX, 0), radius: notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(dividerX, size.height),
          radius: notchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, size.height / 2),
          radius: notchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, size.height / 2),
          radius: notchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) =>
      oldClipper.stubWidth != stubWidth ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.cornerRadius != cornerRadius;
}

class _DashedDividerPainter extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    var y = 16.0;
    while (y < size.height - 16) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
