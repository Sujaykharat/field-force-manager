import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_service.dart';
import '../domain/ai_insight_model.dart';
import '../../tasks/presentation/task_notifier.dart';
import '../../tasks/data/task_repository.dart';

final aiServiceProvider = Provider<AIService>((ref) => MockAIService());

final aiInsightProvider = StateNotifierProvider.family<AIInsightNotifier, AIInsight?, String>((ref, taskId) {
  return AIInsightNotifier(ref.watch(aiServiceProvider), ref.watch(taskRepositoryProvider), taskId);
});

class AIInsightNotifier extends StateNotifier<AIInsight?> {
  final AIService _aiService;
  final TaskRepository _repository;
  final String _taskId;

  AIInsightNotifier(this._aiService, this._repository, this._taskId) : super(null) {
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    state = await _repository.getAIInsight(_taskId);
  }

  Future<void> generateInsight(String notes) async {
    final insight = await _aiService.analyzeNotes(notes);
    await _repository.saveAIInsight(_taskId, insight);
    state = insight;
  }
}
