import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_notifier.dart';
import 'activity_notifier.dart';
import 'widgets/activity_tile.dart';

class ActivityTimelineScreen extends ConsumerWidget {
  final String taskId;

  const ActivityTimelineScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Timeline'),
      ),
      body: activities.isEmpty
          ? const Center(child: Text('No activities found'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return ActivityTile(
                  log: activities[index],
                  isLast: index == activities.length - 1,
                );
              },
            ),
    );
  }
}
