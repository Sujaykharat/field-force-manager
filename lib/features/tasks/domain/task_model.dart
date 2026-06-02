enum TaskStatus {
  pending,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String assignedToName;
  final String assignedBy; // User ID
  final TaskStatus status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.assignedBy,
    required this.status,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToName,
    TaskStatus? status,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedBy: assignedBy,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
