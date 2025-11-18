import 'package:flutter/foundation.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  String? _token;
  int? _userId;
  String? _username;
  String? _displayName;
  String? _email;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  int? get userId => _userId;
  String? get username => _username;
  String? get displayName => _displayName;
  String? get email => _email;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    _token = await _storageService.getToken();
    final userIdStr = await _storageService.getUserId();
    _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    _username = await _storageService.getUsername();
    _displayName = await _storageService.getDisplayName();
    _email = await _storageService.getEmail();

    // If we have a token but no user ID, fetch it
    if (_token != null && _userId == null) {
      try {
        final apiService = ApiService(token: _token);
        final user = await apiService.getCurrentUser();
        _userId = user.id;
        await _storageService.saveUserId(_userId.toString());
      } catch (e) {
        // Ignore error - will try again later
      }
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      _token = response['token'];
      _username = response['user_nicename'];
      _displayName = response['user_display_name'];
      _email = response['user_email'];

      await _storageService.saveAuthData(
        token: _token!,
        username: _username!,
        displayName: _displayName,
        email: _email,
      );

      // Get user ID
      try {
        final apiService = ApiService(token: _token);
        final user = await apiService.getCurrentUser();
        _userId = user.id;
        await _storageService.saveUserId(_userId.toString());
      } catch (e) {
        // Ignore - will get it later
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    _token = null;
    _userId = null;
    _username = null;
    _displayName = null;
    _email = null;
    notifyListeners();
  }
}
