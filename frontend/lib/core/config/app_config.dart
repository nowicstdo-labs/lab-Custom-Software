/// Centralized Configuration for Astha Diagnostic Application.
class AppConfig {
  /// Base API URL for NestJS backend REST API calls.
  /// Defaults to http://localhost:3000/api/v1 for local development.
  /// Can be overridden at build/run time via:
  /// `flutter run --dart-define=API_BASE_URL=http://your-server-ip:3000/api/v1`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
