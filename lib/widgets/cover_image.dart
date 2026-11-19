import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/widgets/can_placeholder.dart';

class CoverImage extends StatelessWidget {
  const new({required this.url, required this.seed, super.key});

  final String? url;

  /// Picks the placeholder tint so neighbouring products look distinct.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null) return CanPlaceholder(seed: seed);
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => CanPlaceholder(seed: seed),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : CanPlaceholder(seed: seed),
    );
  }
}
