// Configuración central de URLs. En producción se inyecta via --dart-define.
class AppConstants {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );
}