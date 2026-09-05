import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import 'secure_storage_service.dart';

/// Centralized REST API Service for Astha Diagnostic NestJS Backend.
class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String? accessToken;
  static String? refreshToken;
  static Future<bool>? _refreshFuture;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static void setAuthToken(String token) {
    accessToken = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null && accessToken!.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      };

  /// Generic POST HTTP Request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    return _sendRequest(() => http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        ), () => post(endpoint, body));
  }

  /// Generic GET HTTP Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return _sendRequest(() => http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
        ), () => get(endpoint));
  }

  /// Generic PATCH HTTP Request
  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    return _sendRequest(() => http.patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        ), () => patch(endpoint, body));
  }

  /// Generic PUT HTTP Request
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    return _sendRequest(() => http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        ), () => put(endpoint, body));
  }

  /// Generic DELETE HTTP Request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    return _sendRequest(() => http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
        ), () => delete(endpoint));
  }

  /// Internal Request Wrapper with Timeout, Retry & Error Translation
  static Future<Map<String, dynamic>> _sendRequest(
    Future<http.Response> Function() httpRequest,
    Future<Map<String, dynamic>> Function() retryCall,
  ) async {
    try {
      final response = await httpRequest().timeout(_timeoutDuration);
      return _handleResponse(response, retryCall);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Unable to connect to server. Please try again.',
        'isTimeout': true,
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
        'isNetworkError': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred. Please try again.',
      };
    }
  }

  /// Response Handler with Token Refresh Rotation & Status Code Mapping
  static Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retryCall,
  ) async {
    Map<String, dynamic> decoded = {};
    try {
      if (response.body.isNotEmpty) {
        final raw = jsonDecode(response.body);
        if (raw is Map<String, dynamic>) {
          decoded = raw;
        } else {
          decoded = {'data': raw};
        }
      }
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode == 401 && refreshToken != null) {
      _refreshFuture ??= refreshAccessToken().whenComplete(() => _refreshFuture = null);
      final refreshed = await _refreshFuture!;
      if (refreshed) {
        return await retryCall();
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': decoded['data'] ?? decoded,
        'raw': decoded,
      };
    }

    String errorMessage = _extractErrorMessage(decoded, response.statusCode);

    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': errorMessage,
      'raw': decoded,
    };
  }

  static String _extractErrorMessage(Map<String, dynamic> decoded, int statusCode) {
    if (decoded.containsKey('message')) {
      final msg = decoded['message'];
      if (msg is List && msg.isNotEmpty) {
        return msg.first.toString();
      } else if (msg is String && msg.trim().isNotEmpty) {
        return msg;
      }
    }
    if (decoded.containsKey('error') && decoded['error'] is String) {
      return decoded['error'];
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request details provided.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'You do not have permission to access this section.';
      case 404:
        return 'Requested resource was not found.';
      case 409:
        return 'An account or record already exists.';
      case 422:
        return 'Unprocessable request format.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
      case 502:
      case 503:
        return 'Something went wrong on the server. Please try again later.';
      default:
        return 'Unable to connect to server. Please try again.';
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
      ).timeout(const Duration(seconds: 15));

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
