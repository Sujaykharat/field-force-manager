import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../domain/visit_model.dart';
import '../domain/task_model.dart';
import '../domain/activity_model.dart';
import 'task_notifier.dart';
import 'activity_notifier.dart';
import '../../ai/presentation/ai_notifier.dart';

final visitProvider = StateNotifierProvider.family<VisitNotifier, Visit?, String>((ref, taskId) {
  return VisitNotifier(ref.watch(taskRepositoryProvider), ref, taskId);
});

class VisitNotifier extends StateNotifier<Visit?> {
  final TaskRepository _repository;
  final Ref _ref;
  final String _taskId;

  VisitNotifier(this._repository, this._ref, this._taskId) : super(null) {
    _loadVisit();
  }

  Future<void> _loadVisit() async {
    final visits = await _repository.getVisits(_taskId);
    if (visits.isNotEmpty) {
      state = visits.last;
    }
  }

  Future<void> startVisit() async {
    final visit = Visit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: _taskId,
      notes: '',
      outcome: '',
      status: VisitStatus.started,
      createdAt: DateTime.now(),
    );
    await _repository.saveVisit(visit);
    state = visit;
    
    _ref.read(activityProvider(_taskId).notifier).addLog(
      ActivityType.visitStarted,
      'Visit started',
    );
    
    _ref.read(taskProvider.notifier).updateStatus(_taskId, TaskStatus.inProgress);
  }

  Future<void> completeVisit(String notes, String outcome) async {
    if (state == null) return;
    
    final updatedVisit = state!.copyWith(
      notes: notes,
      outcome: outcome,
      status: VisitStatus.completed,
    );
    await _repository.saveVisit(updatedVisit);
    state = updatedVisit;
    
    _ref.read(activityProvider(_taskId).notifier).addLog(
      ActivityType.visitCompleted,
      'Visit completed: $outcome',
    );
    
    // Generate AI Insight
    _ref.read(aiInsightProvider(_taskId).notifier).generateInsight(notes);
    
    _ref.read(taskProvider.notifier).updateStatus(_taskId, TaskStatus.completed);
  }
}
