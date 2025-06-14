import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  /// Must be called once at app startup after Supabase.initialize
  static Future<void> init() async {
    final supabase = Supabase.instance.client;
    // Save current session token if present
    final token = supabase.auth.currentSession?.accessToken;
    if (token != null) {
      await saveToken(token);
    }

    // Listen for auth state changes to refresh token storage
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          if (session?.accessToken != null) {
            await saveToken(session!.accessToken);
          }
          break;
        case AuthChangeEvent.signedOut:
          await logout();
          break;
        default:
          break;
      }
    });
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    print('DEBUG - Token loaded: $token');
    return token;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    print('DEBUG - Token saved: $token');
  }

  static Future<void> logout() async => _storage.delete(key: _tokenKey);

  // login handled by supabase_flutter
}
