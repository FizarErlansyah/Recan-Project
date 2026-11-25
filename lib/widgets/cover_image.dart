import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/widgets/can_placeholder.dart';

class CoverImage extends StatelessWidget {
  const new({
    required this.url,
    required this.seed,
    super.key,
    this.art = ProductArt.can,
  });

  final String? url;

  /// Picks the placeholder tint so neighbouring products look distinct.
  final int seed;
  final ProductArt art;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final placeholder = CanPlaceholder(seed: seed, art: art);
    if (imageUrl == null) return placeholder;
    // Uploaded photos can be camera-sized; decoding them at the tile's own
    // width keeps a grid of them cheap.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                  .round()
            : null;
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: width,
          errorBuilder: (_, _, _) => placeholder,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : placeholder,
        );
      },
    );
  }
}
