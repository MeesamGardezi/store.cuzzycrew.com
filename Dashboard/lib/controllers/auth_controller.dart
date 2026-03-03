import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _accessToken;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Call real backend login endpoint
      final response = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response from server');
      }

      final accessToken = data['tokens']?['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token received');
      }

      // Store token and set in API service
      _accessToken = accessToken;
      ApiService.setAuthToken(accessToken);

      _isLoggedIn = true;
      _userEmail = email;
      debugPrint('✅ Login successful for $email');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Login failed: $_errorMessage');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _accessToken = null;
    _errorMessage = null;
    ApiService.clearAuthToken();
    notifyListeners();
  }
}
