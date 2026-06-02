import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/user_role.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/role_badge.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../../tasks/presentation/task_notifier.dart';
import '../../tasks/domain/task_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final taskState = ref.watch(taskProvider);
    
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Force Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskProvider.notifier).loadTasks(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 32),
              _buildStatsGrid(taskState.tasks),
              const SizedBox(height: 32),
              _buildAnalyticsSection(context, taskState.tasks),
              const SizedBox(height: 32),
              _buildRoleSpecificActions(context, user.role),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            user.name[0],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              Text(
                user.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              RoleBadge(role: user.role),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(List<Task> tasks) {
    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        DashboardCard(
          title: 'Total Tasks',
          value: tasks.length.toString(),
          icon: Icons.assignment,
          color: Colors.blue,
        ),
        DashboardCard(
          title: 'Completed',
          value: completed.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        DashboardCard(
          title: 'Pending',
          value: pending.toString(),
          icon: Icons.pending,
          color: Colors.orange,
        ),
        DashboardCard(
          title: 'In Progress',
          value: inProgress.toString(),
          icon: Icons.sync,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) return const SizedBox();

    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(value: completed.toDouble(), color: Colors.green, title: 'Done', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: 'Todo', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                PieChartSectionData(value: inProgress.toDouble(), color: Colors.purple, title: 'Doing', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSpecificActions(BuildContext context, UserRole role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (role == UserRole.admin) ...[
          _buildActionItem(Icons.assignment, 'View All Tasks', 'Manage system wide tasks', () => context.push('/tasks')),
          _buildActionItem(Icons.add_task, 'Assign Tasks', 'Create and assign new tasks to team', () => context.push('/create-task')),
          _buildActionItem(Icons.people_outline, 'Manage Users', 'Add, edit or remove field force', () => context.push('/manage-users')),
        ],
        if (role == UserRole.regionalManager) ...[
          _buildActionItem(Icons.assignment, 'Team Tasks', 'View tasks in your region', () => context.push('/tasks')),
          _buildActionItem(Icons.add_task, 'Assign Tasks', 'Assign tasks to team leads and agents', () => context.push('/create-task')),
        ],
        if (role == UserRole.teamLead) ...[
          _buildActionItem(Icons.list_alt, 'Team Tasks', 'Review tasks assigned to your team', () => context.push('/tasks')),
          _buildActionItem(Icons.person_add_alt_1, 'Assign Tasks', 'Distribute tasks to agents', () => context.push('/create-task')),
        ],
        if (role == UserRole.fieldAgent) ...[
          _buildActionItem(Icons.my_library_books, 'My Tasks', 'View and update your assigned tasks', () => context.push('/tasks')),
        ],
        if (role == UserRole.auditor) ...[
          _buildActionItem(Icons.assignment, 'Audit Tasks', 'Review all task activities', () => context.push('/tasks')),
        ],
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
