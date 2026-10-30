import 'package:permission_handler/permission_handler.dart';

enum CameraAccess { granted, denied, permanentlyDenied }

class CameraPermissionService {
  const new _();

  static Future<CameraAccess> request() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return CameraAccess.granted;
    if (status.isPermanentlyDenied) return CameraAccess.permanentlyDenied;
    return CameraAccess.denied;
  }

  static Future<bool> openSettings() => openAppSettings();
}
