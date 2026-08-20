import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import 'secure_storage_service.dart';

/// Centralized REST API Service for Astha Diagnostic NestJS Backend.
class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String? accessToken;
  static String? refreshToken;
  static bool _isRefreshing = false;

  static void setAuthToken(String token) {
    accessToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null && accessToken!.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      };

  /// Generic POST HTTP Request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response, () => post(endpoint, body));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Generic GET HTTP Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response, () => get(endpoint));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Generic PATCH HTTP Request
  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response, () => patch(endpoint, body));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Generic PUT HTTP Request
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response, () => put(endpoint, body));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Generic DELETE HTTP Request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response, () => delete(endpoint));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Response Handler with Token Refresh Rotation
  static Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retryCall,
  ) async {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 401 && refreshToken != null && !_isRefreshing) {
        _isRefreshing = true;
        final refreshed = await refreshAccessToken();
        _isRefreshing = false;
        if (refreshed) {
          return await retryCall();
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded['data'] ?? decoded, 'raw': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? decoded['error'] ?? 'API Error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'JSON Decode Error: $e'};
    }
  }

  /// Refresh JWT Access Token Pair
  static Future<bool> refreshAccessToken() async {
    if (refreshToken == null || refreshToken!.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] ?? decoded;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;

        if (newAccess != null && newAccess.isNotEmpty) {
          accessToken = newAccess;
          await SecureStorageService.instance.saveAccessToken(newAccess);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            refreshToken = newRefresh;
            await SecureStorageService.instance.saveRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}

    accessToken = null;
    refreshToken = null;
    await SecureStorageService.instance.clearAll();
    return false;
  }
}

