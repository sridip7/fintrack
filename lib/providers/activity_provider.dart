import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';

class ActivityProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<ActivityLog> _activities = [];
  bool _isLoading = false;

  ActivityProvider(this._dbService);

  List<ActivityLog> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activities = await _dbService.getActivities(email);
    } catch (e) {
      _activities = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logAction(String email, String action, String details) async {
    final log = ActivityLog(action: action, details: details);
    try {
      await _dbService.logActivity(email, log);
      // Avoid a full reload for efficiency, just insert at top
      _activities.insert(0, log);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  void clearActivities() {
    _activities = [];
    notifyListeners();
  }
}
