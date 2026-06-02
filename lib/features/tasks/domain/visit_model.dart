enum VisitStatus {
  notStarted,
  started,
  completed;

  String get displayName {
    switch (this) {
      case VisitStatus.notStarted:
        return 'Not Started';
      case VisitStatus.started:
        return 'Started';
      case VisitStatus.completed:
        return 'Completed';
    }
  }
}

class Visit {
  final String id;
  final String taskId;
  final String notes;
  final String outcome;
  final VisitStatus status;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.taskId,
    required this.notes,
    required this.outcome,
    required this.status,
    required this.createdAt,
  });

  Visit copyWith({
    String? notes,
    String? outcome,
    VisitStatus? status,
  }) {
    return Visit(
      id: id,
      taskId: taskId,
      notes: notes ?? this.notes,
      outcome: outcome ?? this.outcome,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
