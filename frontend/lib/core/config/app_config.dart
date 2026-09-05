import 'package:flutter/foundation.dart';

/// Centralized Configuration for Astha Diagnostic Application.
class AppConfig {
  /// Base API URL for NestJS backend REST API calls.
  /// Dynamically handles Android Emulator localhost vs Web/Desktop localhost.
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://lab-custom-software.onrender.com/api/v1',
    );
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'https://lab-custom-software.onrender.com/api/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://lab-custom-software.onrender.com/api/v1';
    }

    // Default for iOS Simulator, Windows, macOS, Linux
    return 'https://lab-custom-software.onrender.com/api/v1';
  }
}
