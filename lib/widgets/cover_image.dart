import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';

class CoverImage extends StatelessWidget {
  new({
    required this.url,
    super.key,
    AppIconBuilder? placeholderIcon,
    this.placeholderSize = 24,
  }) : placeholderIcon = placeholderIcon ?? _defaultPlaceholderIcon;

  static final AppIconBuilder _defaultPlaceholderIcon = hugeIcon(
    HugeIcons.strokeRoundedRecycle01,
  );

  final String? url;
  final AppIconBuilder placeholderIcon;
  final double placeholderSize;

  Widget _placeholder() => ColoredBox(
    color: AppColors.primarySoft,
    child: Center(
      child: placeholderIcon(color: AppColors.primary, size: placeholderSize),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null) return _placeholder();
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => _placeholder(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder(),
    );
  }
}
