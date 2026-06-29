import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  
  String? _currentUserEmail;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._dbService);

  String? get currentUserEmail => _currentUserEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUserEmail != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if session exists on app launch
  Future<void> checkSession() async {
    _currentUserEmail = _dbService.getCurrentUserEmail();
    notifyListeners();
  }

  // Handle Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password fields cannot be empty.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _dbService.loginUser(email, password);
      if (success) {
        _currentUserEmail = email.trim().toLowerCase();
        await _dbService.logActivity(_currentUserEmail!, ActivityLog(
          action: 'Logged In',
          details: 'Successfully logged into the account.'
        ));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Handle Sign Up
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password fields cannot be empty.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _errorMessage = 'Please enter a valid email address.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters long.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _dbService.registerUser(email, password);
      if (success) {
        // Automatically login the user upon registration
        await _dbService.loginUser(email, password);
        _currentUserEmail = email.trim().toLowerCase();
        await _dbService.logActivity(_currentUserEmail!, ActivityLog(
          action: 'Account Created',
          details: 'Successfully registered a new account.'
        ));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'An account with this email already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Handle Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _dbService.logout();
    _currentUserEmail = null;
    _isLoading = false;
    notifyListeners();
  }

  // Handle Account Deletion
  Future<bool> deleteAccount() async {
    if (_currentUserEmail == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final email = _currentUserEmail!;
      await _dbService.deleteUserAccount(email);
      _currentUserEmail = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred while deleting your account.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Verify Password
  Future<bool> verifyPassword(String email, String password) async {
    return await _dbService.loginUser(email, password);
  }
}
