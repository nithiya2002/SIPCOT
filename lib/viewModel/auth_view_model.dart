import 'package:flutter/material.dart';
import 'package:sipcot/model/user_model.dart';
import 'package:sipcot/repositories/auth_repository.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AuthViewModel() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _repository.getUserModel();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email) async {
    // Validate email
    if (!_validateEmail(email)) {
      _error = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = UserModel(email: email);
      await _repository.saveUser(user);
      _currentUser = user;
    } catch (e) {
      _error = 'Failed to login. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? getRouteForUser() {
    if (_currentUser == null) return '/login';

    switch (_currentUser!.email) {
      case 'admin@gmail.com':
        return '/admin';
      case 'survey@gmail.com':
        return '/survey';
      default:
        return '/survey'; // Default route for other emails
    }
  }
}
