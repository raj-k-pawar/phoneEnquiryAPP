import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user    => _user;
  bool       get loading => _loading;
  String?    get error   => _error;
  bool       get loggedIn => _user != null;
  bool       get isAdmin  => _user?.role == 'admin';

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await ApiService.login(username, password);
      // user is UserModel (non-nullable) returned from ApiService.login
      _user = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyToken,    user.token);
      await prefs.setString(AppConstants.keyRole,     user.role);
      await prefs.setInt   (AppConstants.keyUserId,   user.id);
      await prefs.setString(AppConstants.keyUserName, user.name);
      await prefs.setString(AppConstants.keyUsername,  user.username);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    if (token == null || token.isEmpty) return;
    _user = UserModel(
      id:       prefs.getInt(AppConstants.keyUserId) ?? 0,
      name:     prefs.getString(AppConstants.keyUserName) ?? '',
      username: prefs.getString(AppConstants.keyUsername)  ?? '',
      role:     prefs.getString(AppConstants.keyRole)      ?? 'manager',
      token:    token,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
