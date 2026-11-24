import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/data_refresh.dart';

class ProfileService {
  const new _();

  static bool get canEditEmail => Backend.current.canEditEmail;

  static Future<ProfileData> fetchProfile() => Backend.current.profile();

  static Future<ProfileOverview> fetchOverview() => Backend.current.overview();

  static Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    await Backend.current.updateProfile(name: name, email: email, phone: phone);
    DataRefresh.notifyChanged();
  }

  static Future<void> connectGoPay() async {
    await Backend.current.connectGoPay();
    DataRefresh.notifyChanged();
  }

  static Future<AvatarRef> updateAvatar(String sourcePath) async {
    final avatar = await Backend.current.updateAvatar(sourcePath);
    DataRefresh.notifyChanged();
    return avatar;
  }

  static Future<AvatarRef> removeAvatar() async {
    final avatar = await Backend.current.removeAvatar();
    DataRefresh.notifyChanged();
    return avatar;
  }

  static Future<void> restoreAvatar() => Backend.current.restoreAvatar();
}
