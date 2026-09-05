import 'package:flutter/foundation.dart';

/// Centralized Configuration for Astha Diagnostic Application.
class AppConfig {
  /// Base API URL for NestJS backend REST API calls.
  /// Dynamically handles Android Emulator localhost vs Web/Desktop localhost.
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:3000/api/v1';
    }

    // Default for iOS Simulator, Windows, macOS, Linux
    return 'http://localhost:3000/api/v1';
  }
}
