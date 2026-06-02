import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/create_task_screen.dart';
import '../../features/tasks/presentation/visit_update_screen.dart';
import '../../features/tasks/presentation/activity_timeline_screen.dart';
import '../../features/tasks/domain/task_model.dart';
import '../../features/dashboard/presentation/search_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/user_management_screen.dart';
import '../../features/ai/presentation/ai_insight_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/manage-users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/task-details',
        builder: (context, state) {
          final task = state.extra as Task;
          return TaskDetailsScreen(task: task);
        },
      ),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: '/visit-update',
        builder: (context, state) {
          final task = state.extra as Task;
          return VisitUpdateScreen(task: task);
        },
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) {
          final taskId = state.extra as String;
          return ActivityTimelineScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/ai-insight',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AIInsightScreen(
            taskId: extra['taskId'],
            originalNotes: extra['notes'],
          );
        },
      ),
    ],
  );
});
