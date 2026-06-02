import '../domain/ai_insight_model.dart';

abstract class AIService {
  Future<AIInsight> analyzeNotes(String notes);
}

class MockAIService implements AIService {
  @override
  Future<AIInsight> analyzeNotes(String notes) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 1));
    
    final lowerNotes = notes.toLowerCase();
    
    String priority = 'Medium';
    String summary = notes.length > 50 ? '${notes.substring(0, 47)}...' : notes;
    String recommendation = 'General follow-up required.';
    bool warningFlag = false;

    if (lowerNotes.contains('unhappy') || 
        lowerNotes.contains('complaint') || 
        lowerNotes.contains('issue') || 
        lowerNotes.contains('urgent')) {
      priority = 'High';
      recommendation = 'Escalate to manager immediately and schedule urgent callback.';
      warningFlag = true;
    } else if (lowerNotes.contains('satisfied') || 
               lowerNotes.contains('completed') || 
               lowerNotes.contains('positive')) {
      priority = 'Low';
      recommendation = 'Archive visit and update client history.';
      warningFlag = false;
    } else if (lowerNotes.contains('interested') || 
               lowerNotes.contains('potential')) {
      priority = 'Medium';
      recommendation = 'Send marketing materials and follow up next week.';
      warningFlag = false;
    }

    // Basic summary logic
    if (lowerNotes.contains('delay')) {
      summary = 'Customer experiencing delivery delays.';
    } else if (lowerNotes.contains('technical')) {
      summary = 'Technical assistance requested at site.';
    }

    return AIInsight(
      summary: summary,
      priority: priority,
      recommendation: recommendation,
      warningFlag: warningFlag,
    );
  }
}
