import 'package:flutter/material.dart';
import '../models/user_role.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getRoleColor(role).withValues(alpha: 0.5)),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.regionalManager:
        return Colors.purple;
      case UserRole.teamLead:
        return Colors.blue;
      case UserRole.fieldAgent:
        return Colors.green;
      case UserRole.auditor:
        return Colors.orange;
    }
  }
}
