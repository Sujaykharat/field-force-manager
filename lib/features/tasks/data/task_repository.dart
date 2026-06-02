import 'package:hive_flutter/hive_flutter.dart';
import '../domain/task_model.dart';
import '../domain/visit_model.dart';
import '../domain/activity_model.dart';
import '../../ai/domain/ai_insight_model.dart';

class TaskRepository {
  final _taskBox = Hive.box('tasks');
  final _visitBox = Hive.box('visits');
  final _activityBox = Hive.box('activities');
  final _aiBox = Hive.box('ai_insights');

  TaskRepository() {
    _seedDataIfNeeded();
  }

  void _seedDataIfNeeded() {
    if (_taskBox.isEmpty) {
      final now = DateTime.now();
      final seedTasks = [
        Task(id: '1', title: 'Store Audit - Downtown', description: 'Perform quarterly inventory audit.', assignedTo: '4', assignedToName: 'Mike Agent', assignedBy: '1', status: TaskStatus.inProgress, createdAt: now.subtract(const Duration(days: 2))),
        Task(id: '2', title: 'Site Survey - West Plaza', description: 'Technical survey for equipment.', assignedTo: '4', assignedToName: 'Mike Agent', assignedBy: '1', status: TaskStatus.pending, createdAt: now.subtract(const Duration(days: 1))),
        Task(id: '3', title: 'Client Meeting - TechCorp', description: 'Discuss service renewal.', assignedTo: '4', assignedToName: 'Mike Agent', assignedBy: '2', status: TaskStatus.completed, createdAt: now.subtract(const Duration(days: 5))),
        Task(id: '4', title: 'Equipment Maintenance', description: 'Routine checkup.', assignedTo: '4', assignedToName: 'Mike Agent', assignedBy: '3', status: TaskStatus.pending, createdAt: now),
        Task(id: '5', title: 'Safety Inspection', description: 'Fire safety verification.', assignedTo: '3', assignedToName: 'Sarah Lead', assignedBy: '1', status: TaskStatus.completed, createdAt: now.subtract(const Duration(days: 10))),
        Task(id: '6', title: 'Network Optimization', description: 'Upgrade router firmware.', assignedTo: '4', assignedToName: 'Mike Agent', assignedBy: '2', status: TaskStatus.inProgress, createdAt: now.subtract(const Duration(hours: 5))),
      ];
      for (var task in seedTasks) {
        _taskBox.put(task.id, _taskToMap(task));
      }
    }
  }

  Map<String, dynamic> _taskToMap(Task task) => {
    'id': task.id,
    'title': task.title,
    'description': task.description,
    'assignedTo': task.assignedTo,
    'assignedToName': task.assignedToName,
    'assignedBy': task.assignedBy,
    'status': task.status.name,
    'createdAt': task.createdAt.toIso8601String(),
  };

  Task _mapToTask(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    assignedTo: map['assignedTo'],
    assignedToName: map['assignedToName'],
    assignedBy: map['assignedBy'],
    status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
    createdAt: DateTime.parse(map['createdAt']),
  );

  Future<List<Task>> getTasks() async {
    return _taskBox.values.map((e) => _mapToTask(Map<String, dynamic>.from(e))).toList();
  }

  Future<Task> addTask(Task task) async {
    await _taskBox.put(task.id, _taskToMap(task));
    return task;
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final taskMap = _taskBox.get(taskId);
    if (taskMap != null) {
      final task = _mapToTask(Map<String, dynamic>.from(taskMap));
      await _taskBox.put(taskId, _taskToMap(task.copyWith(status: status)));
    }
  }

  Future<List<Visit>> getVisits(String taskId) async {
    return _visitBox.values
        .where((e) => e['taskId'] == taskId)
        .map((e) => _mapToVisit(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _visitToMap(Visit visit) => {
    'id': visit.id,
    'taskId': visit.taskId,
    'notes': visit.notes,
    'outcome': visit.outcome,
    'status': visit.status.name,
    'createdAt': visit.createdAt.toIso8601String(),
  };

  Visit _mapToVisit(Map<String, dynamic> map) => Visit(
    id: map['id'],
    taskId: map['taskId'],
    notes: map['notes'],
    outcome: map['outcome'],
    status: VisitStatus.values.firstWhere((e) => e.name == map['status']),
    createdAt: DateTime.parse(map['createdAt']),
  );

  Future<void> saveVisit(Visit visit) async {
    await _visitBox.put(visit.id, _visitToMap(visit));
  }

  Future<List<ActivityLog>> getActivities(String taskId) async {
    return _activityBox.values
        .where((e) => e['taskId'] == taskId)
        .map((e) => _mapToActivity(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _activityToMap(ActivityLog log) => {
    'id': log.id,
    'taskId': log.taskId,
    'type': log.type.name,
    'message': log.message,
    'timestamp': log.timestamp.toIso8601String(),
  };

  ActivityLog _mapToActivity(Map<String, dynamic> map) => ActivityLog(
    id: map['id'],
    taskId: map['taskId'],
    type: ActivityType.values.firstWhere((e) => e.name == map['type']),
    message: map['message'],
    timestamp: DateTime.parse(map['timestamp']),
  );

  Future<void> logActivity(ActivityLog log) async {
    await _activityBox.put(log.id, _activityToMap(log));
  }

  // AI Insight methods
  Future<void> saveAIInsight(String taskId, AIInsight insight) async {
    await _aiBox.put(taskId, insight.toJson());
  }

  Future<AIInsight?> getAIInsight(String taskId) async {
    final data = _aiBox.get(taskId);
    if (data != null) {
      return AIInsight.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}
