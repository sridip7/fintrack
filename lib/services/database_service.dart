import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/activity_log.dart';

class DatabaseService {
  static const String _settingsBoxName = 'settings_box';
  static const String _authBoxName = 'auth_box';
  static const String _userSessionKey = 'current_user_email';

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_authBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // Settings: Theme Mode
  String getThemeMode(String email) {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_themeMode';
    return settingsBox.get(key, defaultValue: 'system') as String;
  }

  Future<void> setThemeMode(String email, String mode) async {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_themeMode';
    await settingsBox.put(key, mode);
  }

  // Settings: Theme Palette
  String getThemePalette(String email) {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_themePalette';
    return settingsBox.get(key, defaultValue: 'indigo') as String;
  }

  Future<void> setThemePalette(String email, String palette) async {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_themePalette';
    await settingsBox.put(key, palette);
  }

  // Settings: Currency
  String getCurrency(String email) {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_currency';
    return settingsBox.get(key, defaultValue: 'USD') as String;
  }

  Future<void> setCurrency(String email, String currencyCode) async {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_currency';
    await settingsBox.put(key, currencyCode);
  }

  // Settings: Full Name
  String getFullName(String email) {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_fullName';
    return settingsBox.get(key, defaultValue: '') as String;
  }

  Future<void> setFullName(String email, String fullName) async {
    final settingsBox = Hive.box(_settingsBoxName);
    final key = '${email.trim().toLowerCase()}_fullName';
    await settingsBox.put(key, fullName);
  }

  // Delete User Account and all scoped data
  Future<void> deleteUserAccount(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    // 1. Delete credentials from auth_box
    final authBox = Hive.box(_authBoxName);
    await authBox.delete(normalizedEmail);

    // 2. Clear current session if this user was logged in
    final currentSession = authBox.get(_userSessionKey) as String?;
    if (currentSession == normalizedEmail) {
      await authBox.delete(_userSessionKey);
    }

    // 3. Delete user-specific settings
    final settingsBox = Hive.box(_settingsBoxName);
    await settingsBox.delete('${normalizedEmail}_themeMode');
    await settingsBox.delete('${normalizedEmail}_themePalette');
    await settingsBox.delete('${normalizedEmail}_currency');
    await settingsBox.delete('${normalizedEmail}_fullName');

    // 4. Clear and delete transactions box from disk
    final txBoxName = _getTransactionBoxName(email);
    if (await Hive.boxExists(txBoxName)) {
      final txBox = await Hive.openBox<Map>(txBoxName);
      await txBox.clear();
      await txBox.close();
      await Hive.deleteBoxFromDisk(txBoxName);
    }

    // 5. Clear and delete activity box from disk
    final activityBoxName = _getActivityBoxName(email);
    if (await Hive.boxExists(activityBoxName)) {
      final activityBox = await Hive.openBox<Map>(activityBoxName);
      await activityBox.clear();
      await activityBox.close();
      await Hive.deleteBoxFromDisk(activityBoxName);
    }
  }

  // Register a user
  Future<bool> registerUser(String email, String password) async {
    final authBox = Hive.box(_authBoxName);
    final normalizedEmail = email.trim().toLowerCase();

    if (authBox.containsKey(normalizedEmail)) {
      return false; // User already exists
    }

    // In a real application, you should hash the password before saving
    await authBox.put(normalizedEmail, password);
    return true;
  }

  // Validate login credentials
  Future<bool> loginUser(String email, String password) async {
    final authBox = Hive.box(_authBoxName);
    final normalizedEmail = email.trim().toLowerCase();

    if (!authBox.containsKey(normalizedEmail)) {
      return false; // User does not exist
    }

    final storedPassword = authBox.get(normalizedEmail) as String;
    if (storedPassword == password) {
      await authBox.put(_userSessionKey, normalizedEmail);
      return true;
    }
    return false;
  }

  // Get active session if any
  String? getCurrentUserEmail() {
    final authBox = Hive.box(_authBoxName);
    return authBox.get(_userSessionKey) as String?;
  }

  // Clear current active session (Logout)
  Future<void> logout() async {
    final authBox = Hive.box(_authBoxName);
    await authBox.delete(_userSessionKey);
  }

  // Get user-specific box name for transactions
  String _getTransactionBoxName(String email) {
    // Replace characters that are not allowed in Hive box names (e.g., '@', '.')
    final cleanEmail = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'transactions_$cleanEmail';
  }

  // Fetch transactions for a user
  Future<List<Transaction>> getTransactions(String email) async {
    final boxName = _getTransactionBoxName(email);
    final box = await Hive.openBox<Map>(boxName);
    
    final List<Transaction> transactions = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        // Cast to Map<String, dynamic> and parse
        final map = Map<String, dynamic>.from(value);
        transactions.add(Transaction.fromJson(map));
      }
    }
    // Sort transactions by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // Save or update a transaction
  Future<void> saveTransaction(String email, Transaction transaction) async {
    final boxName = _getTransactionBoxName(email);
    final box = await Hive.openBox<Map>(boxName);
    await box.put(transaction.id, transaction.toJson());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String email, String id) async {
    final boxName = _getTransactionBoxName(email);
    final box = await Hive.openBox<Map>(boxName);
    await box.delete(id);
  }

  // --- ACTIVITY LOGS ---

  String _getActivityBoxName(String email) {
    final cleanEmail = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'activities_$cleanEmail';
  }

  Future<void> logActivity(String email, ActivityLog log) async {
    final boxName = _getActivityBoxName(email);
    final box = await Hive.openBox<Map>(boxName);
    await box.put(log.id, log.toJson());
  }

  Future<List<ActivityLog>> getActivities(String email) async {
    final boxName = _getActivityBoxName(email);
    final box = await Hive.openBox<Map>(boxName);
    
    final List<ActivityLog> activities = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        final map = Map<String, dynamic>.from(value);
        activities.add(ActivityLog.fromJson(map));
      }
    }
    // Sort descending by timestamp
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}
