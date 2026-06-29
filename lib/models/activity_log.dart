import 'package:uuid/uuid.dart';

class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String action;
  final String details;

  ActivityLog({
    String? id,
    DateTime? timestamp,
    required this.action,
    required this.details,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'details': details,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      details: json['details'] as String,
    );
  }
}
