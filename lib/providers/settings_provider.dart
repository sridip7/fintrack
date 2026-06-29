import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';

enum AppThemePalette {
  indigo,
  green,
  rose,
  teal,
  amber,
}

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  ThemeMode _themeMode = ThemeMode.system;
  String _themePalette = 'indigo';
  String _currencyCode = 'USD';
  String _fullName = '';

  SettingsProvider(this._dbService);

  ThemeMode get themeMode => _themeMode;
  String get themePalette => _themePalette;
  String get currencyCode => _currencyCode;
  String get fullName => _fullName;

  // Get active currency symbol
  String get currencySymbol {
    switch (_currencyCode) {
      case 'INR':
        return '₹';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'USD':
      default:
        return '\$';
    }
  }

  // Map palette string to visual seed color for ThemeData
  Color get themeColorSeed {
    switch (_themePalette) {
      case 'green':
        return const Color(0xFF10B981);
      case 'rose':
        return const Color(0xFFED4C67);
      case 'teal':
        return const Color(0xFF009688);
      case 'amber':
        return const Color(0xFFFF9F43);
      case 'indigo':
      default:
        return const Color(0xFF6366F1);
    }
  }

  // Load user settings on login or session check
  Future<void> loadSettings(String email) async {
    final modeStr = _dbService.getThemeMode(email);
    _themeMode = _parseThemeMode(modeStr);

    _themePalette = _dbService.getThemePalette(email);
    _currencyCode = _dbService.getCurrency(email);
    _fullName = _dbService.getFullName(email);
    notifyListeners();
  }

  // Update theme mode
  Future<void> updateThemeMode(String email, String mode) async {
    await _dbService.setThemeMode(email, mode);
    _themeMode = _parseThemeMode(mode);
    await _dbService.logActivity(email, ActivityLog(
      action: 'Changed Theme Mode',
      details: 'Theme mode updated to $mode.'
    ));
    notifyListeners();
  }

  // Update theme color palette
  Future<void> updateThemePalette(String email, String palette) async {
    await _dbService.setThemePalette(email, palette);
    _themePalette = palette;
    await _dbService.logActivity(email, ActivityLog(
      action: 'Changed Theme Palette',
      details: 'Theme color palette updated to $palette.'
    ));
    notifyListeners();
  }

  // Update currency code
  Future<void> updateCurrency(String email, String currencyCode) async {
    await _dbService.setCurrency(email, currencyCode);
    _currencyCode = currencyCode;
    await _dbService.logActivity(email, ActivityLog(
      action: 'Changed Currency',
      details: 'Display currency updated to $currencyCode.'
    ));
    notifyListeners();
  }

  // Update full name
  Future<void> updateFullName(String email, String fullName) async {
    await _dbService.setFullName(email, fullName);
    _fullName = fullName;
    notifyListeners();
  }

  // Reset to default settings on logout
  void clearSettings() {
    _themeMode = ThemeMode.system;
    _themePalette = 'indigo';
    _currencyCode = 'USD';
    _fullName = '';
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
