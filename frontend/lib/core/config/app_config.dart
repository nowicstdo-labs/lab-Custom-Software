/// Centralized Configuration for Astha Diagnostic Application.
class AppConfig {
  /// Base API URL for NestJS backend REST API calls.
  /// Defaults to live production backend on Render: https://astha-diagnostic-2.onrender.com/api/v1
  /// Can be overridden at build/run time for local development via:
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://astha-diagnostic-2.onrender.com/api/v1',
  );
}
