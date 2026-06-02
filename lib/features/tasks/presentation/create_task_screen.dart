import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/domain/auth_state.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/utils/permission_service.dart';
import 'task_notifier.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _selectedUserId != null && _selectedUserName != null) {
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        ref.read(taskProvider.notifier).createTask(
          _titleController.text.trim(),
          _descController.text.trim(),
          _selectedUserId!,
          _selectedUserName!,
          authState.user.id,
        );
        
        context.pop();
      }
    } else if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usersAsync = ref.watch(usersProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                hintText: 'Enter task title',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descController,
                label: 'Description',
                hintText: 'Enter detailed description',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Assign To',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              usersAsync.when(
                data: (users) {
                  final assignableUsers = PermissionService.getAssignableUsers(currentUser, users);
                  
                  if (assignableUsers.isEmpty) {
                    return const Text('No users available for assignment', style: TextStyle(color: Colors.red));
                  }

                  return DropdownButtonFormField<UserModel>(
                    value: _selectedUserId != null 
                        ? assignableUsers.firstWhere((u) => u.id == _selectedUserId) 
                        : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: assignableUsers.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text('${user.name} (${user.role.name})'),
                      );
                    }).toList(),
                    onChanged: (user) {
                      setState(() {
                        _selectedUserId = user?.id;
                        _selectedUserName = user?.name;
                      });
                    },
                    hint: const Text('Select User'),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading users: $err'),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Create Task',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
