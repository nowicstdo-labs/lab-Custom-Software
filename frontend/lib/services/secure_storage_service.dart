import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/auth_models.dart';

/// Centralized Secure Storage Service for storing sensitive auth credentials.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _accessTokenKey = 'astha_access_token';
  static const String _refreshTokenKey = 'astha_refresh_token';
  static const String _userSessionKey = 'astha_user_session';

  /// Securely save JWT Access Token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (_) {}
  }

  /// Read JWT Access Token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Securely save JWT Refresh Token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (_) {}
  }

  /// Read JWT Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Securely save authenticated AppUser session object
  Future<void> saveUserSession(AppUser user) async {
    try {
      final jsonStr = jsonEncode(user.toJson());
      await _storage.write(key: _userSessionKey, value: jsonStr);
    } catch (_) {}
  }

  /// Read authenticated AppUser session object
  Future<AppUser?> getUserSession() async {
    try {
      final jsonStr = await _storage.read(key: _userSessionKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return AppUser.fromJson(map);
      }
    } catch (_) {}
    return null;
  }

  /// Clear all stored tokens and user session information (e.g. on Logout)
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userSessionKey);
    } catch (_) {}
  }
}
