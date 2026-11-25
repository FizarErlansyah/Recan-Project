import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';

/// The coloured icon tile of a voucher; it travels from the ticket to the
/// detail screen.
class VoucherEmblem extends StatelessWidget {
  const new({required this.voucher, super.key, this.size = 56});

  static String heroTag(Voucher voucher) => 'voucher-${voucher.id}';

  final Voucher voucher;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: voucher.colors,
        ),
        borderRadius: BorderRadius.circular(AppDecorations.controlRadius),
      ),
      child: HugeIcon(
        icon: voucher.icon,
        color: AppColors.white,
        size: size * 0.5,
      ),
    );
  }
}
