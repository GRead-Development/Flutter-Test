class ApiConfig {
  static const String baseUrl = 'https://gread.fun/wp-json';
  static const String greadNamespace = 'gread/v1';
  static const String buddypressNamespace = 'buddypress/v1';
  static const String jwtNamespace = 'jwt-auth/v1';

  // Full endpoints
  static const String jwtTokenUrl = '$baseUrl/$jwtNamespace/token';
  static const String greadBaseUrl = '$baseUrl/$greadNamespace';
  static const String buddypressBaseUrl = '$baseUrl/$buddypressNamespace';

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
}
