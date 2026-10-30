import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/quick_action_button.dart';

class PointsHeader extends StatelessWidget {
  const new({
    required this.user,
    required this.onScan,
    required this.onRedeem,
    super.key,
    this.trailing,
  });

  static const int rupiahPerPoint = 1;
  static const double _balanceFontSize = 44;
  static const double _curveDepth = 32;

  final UserProfile user;
  final Widget? trailing;
  final VoidCallback onScan;
  final VoidCallback onRedeem;

  static String formatNumber(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).padding.top;
    final rupiah = formatNumber(user.pointsBalance * rupiahPerPoint);

    return ClipPath(
      clipper: const _CurvedBottomClipper(depth: _curveDepth),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, _curveDepth + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Halo,', 'Hello,'),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primarySoft,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing!],
              ],
            ),
            const SizedBox(height: 32),
            Text(
              tr('Saldo Poin', 'Points Balance'),
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primarySoft,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: user.pointsBalance),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        formatNumber(value),
                        style: textTheme.displaySmall?.copyWith(
                          color: AppColors.white,
                          fontSize: _balanceFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tr('poin', 'points'),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primarySoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '≈ Rp$rupiah',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primarySoft,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.recycling_rounded,
                    label: tr('Setor Kaleng', 'Drop Cans'),
                    filled: true,
                    onPressed: onScan,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.card_giftcard_rounded,
                    label: tr('Tukar Poin', 'Redeem Points'),
                    filled: false,
                    onPressed: onRedeem,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  const new({required this.depth});

  final double depth;

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - depth)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + depth / 2,
        size.width,
        size.height - depth,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_CurvedBottomClipper oldClipper) =>
      oldClipper.depth != depth;
}
