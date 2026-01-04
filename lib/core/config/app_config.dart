/// Configuración de la aplicación por entornos
library;

enum Environment { dev, staging, prod }

class AppConfig {
  final String apiBaseUrl;
  final String appName;
  final Environment environment;
  final bool enableLogging;

  const AppConfig._({
    required this.apiBaseUrl,
    required this.appName,
    required this.environment,
    required this.enableLogging,
  });

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static void initialize(Environment env) {
    switch (env) {
      case Environment.dev:
        _instance = const AppConfig._(
          apiBaseUrl: 'https://mingo-api-enterprise.onrender.com/api/v1', // Android emulator localhost
          appName: 'MinGO Dev',
          environment: Environment.dev,
          enableLogging: true,
        );
        break;
      case Environment.staging:
        _instance = const AppConfig._(
          apiBaseUrl: 'https://mingo-api-enterprise.onrender.com/api/v1',
          appName: 'MinGO Staging',
          environment: Environment.staging,
          enableLogging: true,
        );
        break;
      case Environment.prod:
        _instance = const AppConfig._(
          apiBaseUrl: 'https://mingo-api-enterprise.onrender.com/api/v1',
          appName: 'MinGO',
          environment: Environment.prod,
          enableLogging: false,
        );
        break;
    }
  }

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;
}
