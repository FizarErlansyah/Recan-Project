import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the profile photo on the device. The picker hands back a cache file
/// the OS may purge, so the photo is copied into app storage and its path is
/// remembered across launches.
abstract final class AvatarStore {
  static const String _key = 'avatar_path';
  static const String _folder = 'avatars';
  static const String _fallbackExtension = '.jpg';

  @visibleForTesting
  static Future<Directory> Function() documentsDirectory =
      getApplicationDocumentsDirectory;

  static Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key);
    if (path == null) return null;
    if (File(path).existsSync()) return path;
    await prefs.remove(_key);
    return null;
  }

  static Future<String> save(String sourcePath) async {
    final root = await documentsDirectory();
    final folder = await Directory('${root.path}/$_folder')
        .create(recursive: true);
    // A new name per save: FileImage caches by path, so reusing one name would
    // keep showing the previous photo.
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final target = '${folder.path}/avatar_$stamp${_extensionOf(sourcePath)}';
    await File(sourcePath).copy(target);

    final prefs = await SharedPreferences.getInstance();
    final previous = prefs.getString(_key);
    await prefs.setString(_key, target);
    if (previous != null) await _deleteQuietly(previous);
    return target;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final previous = prefs.getString(_key);
    await prefs.remove(_key);
    if (previous != null) await _deleteQuietly(previous);
  }

  static String _extensionOf(String path) {
    final name = path.split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    return dot < 0 ? _fallbackExtension : name.substring(dot);
  }

  static Future<void> _deleteQuietly(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
