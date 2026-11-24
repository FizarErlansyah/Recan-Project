import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';

class ProfileAvatar extends StatelessWidget {
  const new({
    required this.initials,
    super.key,
    this.avatar = AvatarRef.none,
    this.size = 88,
    this.color = AppColors.primary,
    this.foreground = AppColors.white,
    this.borderColor,
    this.borderWidth = 4,
  });

  static const double _compactSize = 56;

  final String initials;
  final AvatarRef avatar;
  final double size;
  final Color color;
  final Color foreground;
  final Color? borderColor;
  final double borderWidth;

  ImageProvider? get _image {
    final path = avatar.path;
    if (path != null) return FileImage(File(path));
    final url = avatar.url;
    return url == null ? null : NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle =
        (size < _compactSize ? textTheme.titleSmall : textTheme.headlineSmall)
            ?.copyWith(color: foreground);
    final initialsText = Text(initials, style: labelStyle);
    final image = _image;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: borderColor ?? context.palette.tint,
          width: borderWidth,
        ),
      ),
      child: image == null
          ? initialsText
          : _PhotoDisc(
              image: image,
              diameter: size - borderWidth * 2,
              fallback: initialsText,
            ),
    );
  }
}

class _PhotoDisc extends StatelessWidget {
  const new({
    required this.image,
    required this.diameter,
    required this.fallback,
  });

  final ImageProvider image;
  final double diameter;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final pixels = (diameter * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipOval(
      child: Image(
        image: ResizeImage.resizeIfNeeded(pixels, pixels, image),
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
