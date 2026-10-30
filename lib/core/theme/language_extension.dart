import 'package:flutter/material.dart';

@immutable
class LanguageExtension extends ThemeExtension<LanguageExtension> {
  const new({required this.isEnglish});

  final bool isEnglish;

  @override
  LanguageExtension copyWith({bool? isEnglish}) =>
      LanguageExtension(isEnglish: isEnglish ?? this.isEnglish);

  @override
  LanguageExtension lerp(ThemeExtension<LanguageExtension>? other, double t) =>
      other is LanguageExtension ? other : this;

  @override
  bool operator ==(Object other) =>
      other is LanguageExtension && other.isEnglish == isEnglish;

  @override
  int get hashCode => isEnglish.hashCode;
}
