import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../domain/activity_model.dart';
import 'task_notifier.dart';

final activityProvider = StateNotifierProvider.family<ActivityNotifier, List<ActivityLog>, String>((ref, taskId) {
  return ActivityNotifier(ref.watch(taskRepositoryProvider), taskId);
});

class ActivityNotifier extends StateNotifier<List<ActivityLog>> {
  final TaskRepository _repository;
  final String _taskId;

  ActivityNotifier(this._repository, this._taskId) : super([]) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    final activities = await _repository.getActivities(_taskId);
    state = activities..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addLog(ActivityType type, String message) async {
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: _taskId,
      type: type,
      message: message,
      timestamp: DateTime.now(),
    );
    await _repository.logActivity(log);
    await loadActivities();
  }
}
