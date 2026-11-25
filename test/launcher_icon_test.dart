import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';

/// Pixels per dp of each launcher density bucket.
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

(int, int) _pngSize(File file) {
  final header = ByteData.sublistView(file.readAsBytesSync(), 0, 24);
  return (header.getUint32(16), header.getUint32(20));
}

void main() {
  test('the adaptive icon has background, foreground and themed layers', () {
    final xml = File('$_res/mipmap-anydpi-v26/ic_launcher.xml')
        .readAsStringSync();

    expect(xml, contains('@drawable/ic_launcher_background'));
    for (final layer in ['<foreground', '<monochrome']) {
      expect(xml, contains(layer));
    }
    expect(xml, contains('@mipmap/ic_launcher_foreground'));
    expect(
      File('$_res/drawable/ic_launcher_background.xml').existsSync(),
      true,
    );
  });

  for (final MapEntry(key: density, value: scale) in _densities.entries) {
    test('$density ships both icon sizes', () {
      final legacy = File('$_res/mipmap-$density/ic_launcher.png');
      final front = File('$_res/mipmap-$density/ic_launcher_foreground.png');
      final legacySide = (48 * scale).round();
      final frontSide = (108 * scale).round();

      expect(_pngSize(legacy), (legacySide, legacySide));
      expect(_pngSize(front), (frontSide, frontSide));
      // Colour type 6 keeps the alpha the layer needs.
      expect(front.readAsBytesSync()[25], 6);
    });
  }

  test('the 28 MB artwork never reaches the app bundle', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('icon_app_recan')));
    expect(pubspec, isNot(contains('- assets/images/\n')));
  });
}
