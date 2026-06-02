import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/permission_service.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import 'task_notifier.dart';
import '../domain/task_model.dart';
import 'widgets/task_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chip_group.dart';
import 'widgets/empty_state_widget.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  String _searchQuery = '';
  TaskStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.role;

    // Filter tasks based on role and search/status
    final filteredTasks = taskState.tasks.where((task) {
      // Role filtering
      bool allowedByRole = false;
      if (role == UserRole.admin || role == UserRole.auditor) {
        allowedByRole = true;
      } else if (role == UserRole.regionalManager || role == UserRole.teamLead) {
        // In real app, we would check if task is in their region/team
        allowedByRole = true; 
      } else if (role == UserRole.fieldAgent) {
        allowedByRole = task.assignedTo == user.id;
      }

      if (!allowedByRole) return false;

      // Search filtering
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Status filtering
      final matchesStatus = _selectedStatus == null || task.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          if (PermissionService.canCreateTask(role))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/create-task'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SearchBarWidget(
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                FilterChipGroup(
                  selectedStatus: _selectedStatus,
                  onStatusSelected: (status) => setState(() => _selectedStatus = status as TaskStatus?),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
              child: taskState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTasks.isEmpty
                      ? const EmptyStateWidget(
                          title: 'No Tasks Found',
                          message: 'Try adjusting your filters or search query.',
                          icon: Icons.assignment_late_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => context.push('/task-details', extra: task),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
