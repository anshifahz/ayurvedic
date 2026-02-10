import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _token;

  AuthProvider(this._apiService);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.login(username, password);
      if (token != null) {
        _token = token;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false; 
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
  }
}
