import 'package:image_picker/image_picker.dart';

enum AvatarSource { camera, gallery }

abstract final class AvatarPicker {
  // A profile photo is shown at 104dp at most; 1024px keeps it sharp on dense
  // screens without storing a full camera frame.
  static const double _maxSide = 1024;
  static const int _quality = 85;

  static final ImagePicker _picker = ImagePicker();

  /// Path of the chosen image, or null when the user backs out.
  static Future<String?> pick(AvatarSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        AvatarSource.camera => ImageSource.camera,
        AvatarSource.gallery => ImageSource.gallery,
      },
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
      preferredCameraDevice: CameraDevice.front,
    );
    return file?.path;
  }
}
