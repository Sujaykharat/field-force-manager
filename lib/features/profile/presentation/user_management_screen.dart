import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/role_badge.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock list of users
    final users = [
      {'name': 'System Admin', 'email': 'admin@test.com', 'role': UserRole.admin},
      {'name': 'John Manager', 'email': 'manager@test.com', 'role': UserRole.regionalManager},
      {'name': 'Sarah Lead', 'email': 'lead@test.com', 'role': UserRole.teamLead},
      {'name': 'Mike Agent', 'email': 'agent@test.com', 'role': UserRole.fieldAgent},
      {'name': 'Alex Auditor', 'email': 'auditor@test.com', 'role': UserRole.auditor},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature: Add new user coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: users.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text((user['name'] as String)[0]),
              ),
              title: Text(user['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user['email'] as String),
              trailing: RoleBadge(role: user['role'] as UserRole),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing ${user['name']}...')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
