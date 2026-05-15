// lib/services/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isManager => _currentUser?.role == 'manager';

  final DatabaseService _db = DatabaseService();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserModel? user = await _db.login(username, password);
      if (user != null) {
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id!);
        await prefs.setString('user_role', user.role);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      try {
        final users = await _db.getAllUsers();
        final user = users.firstWhere((u) => u.id == userId);
        _currentUser = user;
        notifyListeners();
      } catch (e) {
        await prefs.remove('user_id');
      }
    }
  }
}
