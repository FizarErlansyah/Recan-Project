import 'package:mobile_apps_recan/services/backend/app_backend.dart';

class AuthException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  const new _();

  static Future<bool> restoreSession() => Backend.current.restoreSession();

  static Future<void> logout() => Backend.current.signOut();

  static Future<void> login(String email, String password) =>
      Backend.current.signIn(email: email.trim(), password: password);

  /// Returns false when the account was created but the email must be
  /// confirmed before the first login.
  static Future<bool> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) => Backend.current.signUp(
    username: username,
    fullName: username,
    email: email.trim(),
    phone: phone,
    password: password,
  );
}
