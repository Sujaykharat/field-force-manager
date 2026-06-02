enum ActivityType {
  taskCreated,
  taskAssigned,
  visitStarted,
  visitCompleted,
  noteAdded,
  statusChanged;

  String get displayName {
    switch (this) {
      case ActivityType.taskCreated:
        return 'Task Created';
      case ActivityType.taskAssigned:
        return 'Task Assigned';
      case ActivityType.visitStarted:
        return 'Visit Started';
      case ActivityType.visitCompleted:
        return 'Visit Completed';
      case ActivityType.noteAdded:
        return 'Note Added';
      case ActivityType.statusChanged:
        return 'Status Changed';
    }
  }
}

class ActivityLog {
  final String id;
  final String taskId;
  final ActivityType type;
  final String message;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.taskId,
    required this.type,
    required this.message,
    required this.timestamp,
  });
}
