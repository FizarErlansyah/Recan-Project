import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class CoverImage extends StatelessWidget {
  const new({
    required this.url,
    super.key,
    this.placeholderIcon = Icons.recycling_rounded,
    this.placeholderSize = 24,
  });

  final String? url;
  final IconData placeholderIcon;
  final double placeholderSize;

  Widget _placeholder() => ColoredBox(
    color: AppColors.primarySoft,
    child: Center(
      child: Icon(
        placeholderIcon,
        size: placeholderSize,
        color: AppColors.primary,
      ),
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
