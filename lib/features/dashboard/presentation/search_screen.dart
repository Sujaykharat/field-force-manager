import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tasks/presentation/task_notifier.dart';
import '../../tasks/presentation/widgets/task_card.dart';
import '../../tasks/presentation/widgets/empty_state_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    
    final results = taskState.tasks.where((task) {
      return task.title.toLowerCase().contains(_query.toLowerCase()) ||
             task.description.toLowerCase().contains(_query.toLowerCase()) ||
             task.assignedToName.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search across tasks...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Start typing to search', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : results.isEmpty
              ? const EmptyStateWidget(
                  title: 'No results found',
                  message: 'Try searching with different keywords.',
                  icon: Icons.search_off,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: results[index],
                      onTap: () => context.push('/task-details', extra: results[index]),
                    );
                  },
                ),
    );
  }
}
