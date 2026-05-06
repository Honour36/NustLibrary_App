class EnvConfig {
  // Replace this with your live Render/Railway URL after deployment
  // Example: 'https://nust-library-api.onrender.com'
  static const String prodBaseUrl = 'https://nust-library-backend.onrender.com';
  static const String devBaseUrl = 'http://localhost:3000';
  
  static const bool isProduction = bool.fromEnvironment('dart.vm.product') || true;

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
  static String get apiBaseUrl => '$baseUrl/api';
  static String get authBaseUrl => '$apiBaseUrl/auth';
}
