import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

/// Centralized REST API Service for Astha Diagnostic NestJS Backend.
class ApiService {
  static String baseUrl = AppConfig.apiBaseUrl;
  static String? accessToken;
  static String? refreshToken;

  static void setAuthToken(String token) {
    accessToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
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
          .timeout(const Duration(seconds: 12));

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
          .timeout(const Duration(seconds: 12));

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
          .timeout(const Duration(seconds: 12));

      return _handleResponse(response, () => patch(endpoint, body));
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

      if (response.statusCode == 401 && refreshToken != null) {
        final refreshed = await refreshAccessToken();
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
    if (refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        accessToken = decoded['data']?['accessToken'] ?? decoded['accessToken'];
        refreshToken = decoded['data']?['refreshToken'] ?? decoded['refreshToken'];
        return true;
      }
    } catch (_) {}

    accessToken = null;
    refreshToken = null;
    return false;
  }
}
