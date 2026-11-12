import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static String? token;

  static const String _mockToken = 'mock-session';

  static Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(ApiConfig.tokenKey);
    return token != null && token!.isNotEmpty;
  }

  static Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
  }

  static Future<void> login(
    String email,
    String password, {
    String? username,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException(
        tr(
          'Email dan kata sandi wajib diisi.',
          'Email and password are required.',
        ),
      );
    }
    MockStore.userEmail = email;
    final trimmedUsername = username?.trim() ?? '';
    if (trimmedUsername.isNotEmpty) {
      MockStore.currentUsername = trimmedUsername;
    }
    token = _mockToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, _mockToken);
  }

  static Future<void> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      throw AuthException(
        tr('Semua kolom wajib diisi.', 'All fields are required.'),
      );
    }
    MockStore.currentUsername = username;
    MockStore.userEmail = email;
    MockStore.userPhone = phone;
    token = _mockToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, _mockToken);
  }
}
