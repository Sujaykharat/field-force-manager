import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/permission_service.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../domain/task_model.dart';
import 'task_notifier.dart';
import 'activity_notifier.dart';
import 'visit_notifier.dart';
import '../../ai/presentation/ai_notifier.dart';
import 'widgets/status_badge.dart';
import 'widgets/activity_tile.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) return const SizedBox();
    
    final user = authState.user;
    final activities = ref.watch(activityProvider(task.id));
    final visit = ref.watch(visitProvider(task.id));
    final aiInsight = ref.watch(aiInsightProvider(task.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (aiInsight != null)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.blue),
              tooltip: 'AI Insight',
              onPressed: () => context.push('/ai-insight', extra: {
                'taskId': task.id,
                'notes': visit?.notes ?? '',
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(task),
            const Divider(height: 40),
            _buildDescription(task),
            const SizedBox(height: 24),
            _buildAssigneeInfo(task),
            const SizedBox(height: 32),
            _buildActivityTimeline(activities),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(context, ref, user, visit),
    );
  }

  Widget _buildHeader(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatusBadge(status: task.status),
            Text(
              DateFormat('MMM d, yyyy').format(task.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          task.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescription(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          task.description,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAssigneeInfo(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(task.assignedToName[0], style: const TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assigned To', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(task.assignedToName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(List<dynamic> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Timeline',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
        if (activities.isEmpty)
          const Text('No activity yet', style: TextStyle(color: Colors.grey))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ActivityTile(
                log: activities[index],
                isLast: index == activities.length - 1,
              );
            },
          ),
      ],
    );
  }

  Widget? _buildActionButtons(BuildContext context, WidgetRef ref, dynamic user, dynamic visit) {
    if (PermissionService.isReadOnly(user.role)) return null;

    final bool isAssignedToMe = task.assignedTo == user.id;
    final bool canUpdate = PermissionService.canUpdateVisit(user.role) && isAssignedToMe;

    if (!canUpdate) return null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => context.push('/visit-update', extra: task),
          child: Text(task.status == TaskStatus.pending ? 'Start Visit' : 'Update Visit'),
        ),
      ),
    );
  }
}
