import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../domain/task_model.dart';
import '../domain/activity_model.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../../../core/utils/permission_service.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider), ref);
});

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super(TaskState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTask(String title, String description, String assignedTo, String assignedToName, String assignedBy) async {
    state = state.copyWith(isLoading: true);
    try {
      // Backend-style validation
      final authState = _ref.read(authProvider);
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      final currentUser = authState.user;
      final allUsers = await _ref.read(authRepositoryProvider).getAllUsers();
      final targetUser = allUsers.firstWhere((u) => u.id == assignedTo);

      if (!PermissionService.canAssignTo(currentUser.role, targetUser.role, currentUserId: currentUser.id, targetUserId: targetUser.id)) {
        throw UnauthorizedAssignmentException('${currentUser.role.name} cannot assign to ${targetUser.role.name}');
      }

      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        assignedBy: assignedBy,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );
      await _repository.addTask(newTask);
      
      final log = ActivityLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: newTask.id,
        type: ActivityType.taskCreated,
        message: 'Task created',
        timestamp: DateTime.now(),
      );
      await _repository.logActivity(log);
      
      await loadTasks();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    try {
      await _repository.updateTaskStatus(taskId, status);
      
      final log = ActivityLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        type: ActivityType.statusChanged,
        message: 'Status changed to ${status.displayName}',
        timestamp: DateTime.now(),
      );
      await _repository.logActivity(log);
      
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
