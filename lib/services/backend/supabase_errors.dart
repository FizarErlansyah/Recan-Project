import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Turns Supabase failures into the friendly, localized exceptions the UI
/// already knows. RPC functions raise a stable code as the exception message
/// (see the error table in supabase/schema.sql); this is where each code gets
/// its sentence.
class SupabaseErrors {
  const new _();

  static String get _network => tr(
    'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
    'Cannot reach the server. Check your internet connection.',
  );

  static String get _generic => tr(
    'Terjadi kesalahan. Coba lagi sebentar lagi.',
    'Something went wrong. Please try again shortly.',
  );

  static String get _sessionExpired => tr(
    'Sesi kamu berakhir. Silakan masuk lagi.',
    'Your session has expired. Please log in again.',
  );

  /// Maps a data or RPC failure. [alreadyClaimed] gives `already_claimed` the
  /// wording of the action that raised it.
  static ApiException api(Object error, {String? alreadyClaimed}) {
    if (error is ApiException) return error;
    if (error is sb.PostgrestException) {
      if (error.code == 'PGRST301' || error.message == 'not_authenticated') {
        return ApiException(_sessionExpired, unauthorized: true);
      }
      final message = _businessMessage(error.message, alreadyClaimed);
      if (message != null) return ApiException(message);
    }
    if (error is sb.AuthSessionMissingException) {
      return ApiException(_sessionExpired, unauthorized: true);
    }
    if (_isNetwork(error)) return ApiException(_network);
    debugPrint('Unmapped backend error: $error');
    return ApiException(_generic);
  }

  /// Maps a sign-in or sign-up failure.
  static AuthException auth(Object error) {
    if (error is AuthException) return error;
    if (error is sb.AuthRetryableFetchException || _isNetwork(error)) {
      return AuthException(_network);
    }
    if (error is sb.AuthException) {
      final code = error.code ?? '';
      final text = error.message.toLowerCase();
      bool has(String needle) => text.contains(needle);

      if (code == 'invalid_credentials' || has('invalid login credentials')) {
        return AuthException(
          tr('Email atau kata sandi salah.', 'Wrong email or password.'),
        );
      }
      if (code == 'user_already_exists' ||
          code == 'email_exists' ||
          has('already registered')) {
        return AuthException(
          tr(
            'Email ini sudah terdaftar. Silakan masuk.',
            'This email is already registered. Please log in.',
          ),
        );
      }
      if (code == 'weak_password' || has('at least 6')) {
        return AuthException(
          tr(
            'Kata sandi minimal 6 karakter.',
            'Password must be at least 6 characters.',
          ),
        );
      }
      if (code == 'email_not_confirmed' || has('not confirmed')) {
        return AuthException(
          tr(
            'Email belum diverifikasi. Cek kotak masukmu.',
            'Your email is not verified yet. Check your inbox.',
          ),
        );
      }
      if (code == 'email_address_invalid' || has('invalid format')) {
        return AuthException(
          tr('Format email tidak valid.', 'Invalid email format.'),
        );
      }
      if (code.startsWith('over_') || has('rate limit')) {
        return AuthException(
          tr(
            'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.',
            'Too many attempts. Please try again in a few minutes.',
          ),
        );
      }
      if (code == 'signup_disabled') {
        return AuthException(
          tr('Pendaftaran sedang ditutup.', 'Sign-ups are currently closed.'),
        );
      }
    }
    debugPrint('Unmapped auth error: $error');
    return AuthException(_generic);
  }

  static String? _businessMessage(String code, String? alreadyClaimed) {
    switch (code) {
      case 'invalid_cans_count':
        return tr('Jumlah kaleng tidak valid.', 'Invalid number of cans.');
      case 'invalid_quantity':
        return tr('Jumlah tidak valid.', 'Invalid quantity.');
      case 'station_not_found':
        return tr('Station tidak ditemukan.', 'Station not found.');
      case 'station_unavailable':
        return tr(
          'Station sedang tidak beroperasi.',
          'This station is not operating right now.',
        );
      case 'station_full':
        return tr(
          'Station sudah penuh. Coba station lain.',
          'This station is full. Try another one.',
        );
      case 'item_not_found':
        return tr('Item tidak ditemukan.', 'Item not found.');
      case 'out_of_stock':
        return tr('Stok produk tidak mencukupi.', 'Not enough product stock.');
      case 'shipping_address_required':
        return tr(
          'Alamat pengiriman wajib diisi',
          'Shipping address is required',
        );
      case 'insufficient_points':
        return tr('Poin kamu tidak cukup.', 'You do not have enough points.');
      case 'quest_not_found':
      case 'quest_not_completed':
        return tr('Misi belum bisa diklaim.', 'Mission cannot be claimed yet.');
      case 'article_not_found':
        return tr('Artikel tidak ditemukan.', 'Article not found.');
      case 'already_claimed':
        return alreadyClaimed ??
            tr('Hadiah ini sudah diklaim.', 'This reward is already claimed.');
    }
    return null;
  }

  static bool _isNetwork(Object error) =>
      error is SocketException ||
      error is TimeoutException ||
      error is HandshakeException ||
      error.runtimeType.toString() == 'ClientException';
}
