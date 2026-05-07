class EnvConfig {
  // Live Render URL
  static const String prodBaseUrl = 'https://nustlibrary-app.onrender.com';
  static const String devBaseUrl = 'http://localhost:3001';
  
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
  static String get apiBaseUrl => '$baseUrl/api';
  static String get authBaseUrl => '$apiBaseUrl/auth';
}
