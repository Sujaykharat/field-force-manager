import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/task_model.dart';
import '../domain/visit_model.dart';
import 'visit_notifier.dart';

class VisitUpdateScreen extends ConsumerStatefulWidget {
  final Task task;

  const VisitUpdateScreen({super.key, required this.task});

  @override
  ConsumerState<VisitUpdateScreen> createState() => _VisitUpdateScreenState();
}

class _VisitUpdateScreenState extends ConsumerState<VisitUpdateScreen> {
  final _notesController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visit = ref.watch(visitProvider(widget.task.id));
    final visitNotifier = ref.read(visitProvider(widget.task.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Visit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            if (visit == null || visit.status == VisitStatus.notStarted)
              _buildStartSection(visitNotifier)
            else if (visit.status == VisitStatus.started)
              _buildUpdateSection(visitNotifier)
            else
              _buildCompletedSection(visit),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Task', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.task.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSection(VisitNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.location_on_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'You are about to start a field visit for this task.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Check-in & Start Visit',
          onPressed: () => notifier.startVisit(),
        ),
      ],
    );
  }

  Widget _buildUpdateSection(VisitNotifier notifier) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.timer, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Visit in Progress', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _notesController,
            label: 'Visit Notes',
            hintText: 'Describe what you did...',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _outcomeController,
            label: 'Outcome',
            hintText: 'Final result of the visit',
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 40),
          PrimaryButton(
            text: 'Complete Visit',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                notifier.completeVisit(_notesController.text, _outcomeController.text);
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(Visit visit) {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        const Text('Visit Completed Successfully', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 24),
        _buildDetailRow('Notes', visit.notes),
        _buildDetailRow('Outcome', visit.outcome),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Back to Details'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
