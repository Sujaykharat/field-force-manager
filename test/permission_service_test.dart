import 'package:flutter_test/flutter_test.dart';
import 'package:field_force_management_system/core/utils/permission_service.dart';
import 'package:field_force_management_system/shared/models/user_role.dart';
import 'package:field_force_management_system/shared/models/user_model.dart';

void main() {
  group('PermissionService Hierarchy Tests', () {
    final adminUser = UserModel(id: '1', name: 'Admin', email: 'admin@test.com', role: UserRole.admin);
    final managerUser = UserModel(id: '2', name: 'Manager', email: 'manager@test.com', role: UserRole.regionalManager);
    final leadUser = UserModel(id: '3', name: 'Lead', email: 'lead@test.com', role: UserRole.teamLead);
    final agentUser = UserModel(id: '4', name: 'Agent', email: 'agent@test.com', role: UserRole.fieldAgent);
    final auditorUser = UserModel(id: '5', name: 'Auditor', email: 'auditor@test.com', role: UserRole.auditor);

    final allUsers = [adminUser, managerUser, leadUser, agentUser, auditorUser];

    test('Admin can assign to anyone', () {
      expect(PermissionService.canAssignTo(UserRole.admin, UserRole.admin), isTrue);
      expect(PermissionService.canAssignTo(UserRole.admin, UserRole.regionalManager), isTrue);
      expect(PermissionService.canAssignTo(UserRole.admin, UserRole.teamLead), isTrue);
      expect(PermissionService.canAssignTo(UserRole.admin, UserRole.fieldAgent), isTrue);
      expect(PermissionService.canAssignTo(UserRole.admin, UserRole.auditor), isTrue);
      
      final assignable = PermissionService.getAssignableUsers(adminUser, allUsers);
      expect(assignable.length, 5);
    });

    test('Regional Manager can assign only to Team Lead and Field Agent', () {
      expect(PermissionService.canAssignTo(UserRole.regionalManager, UserRole.admin), isFalse);
      expect(PermissionService.canAssignTo(UserRole.regionalManager, UserRole.regionalManager), isFalse);
      expect(PermissionService.canAssignTo(UserRole.regionalManager, UserRole.teamLead), isTrue);
      expect(PermissionService.canAssignTo(UserRole.regionalManager, UserRole.fieldAgent), isTrue);
      expect(PermissionService.canAssignTo(UserRole.regionalManager, UserRole.auditor), isFalse);
      
      final assignable = PermissionService.getAssignableUsers(managerUser, allUsers);
      expect(assignable.length, 2);
      expect(assignable, containsAll([leadUser, agentUser]));
    });

    test('Team Lead can assign only to Field Agent and NOT to themselves', () {
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.admin), isFalse);
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.regionalManager), isFalse);
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.teamLead), isFalse); // Base rule for same role
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.teamLead, currentUserId: '3', targetUserId: '3'), isFalse); // Self check
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.fieldAgent), isTrue);
      expect(PermissionService.canAssignTo(UserRole.teamLead, UserRole.auditor), isFalse);
      
      final assignable = PermissionService.getAssignableUsers(leadUser, allUsers);
      expect(assignable.length, 1);
      expect(assignable, contains(agentUser));
    });

    test('Field Agent cannot assign to anyone', () {
      for (var target in UserRole.values) {
        expect(PermissionService.canAssignTo(UserRole.fieldAgent, target), isFalse);
      }
      expect(PermissionService.getAssignableUsers(agentUser, allUsers), isEmpty);
    });

    test('Auditor cannot assign to anyone', () {
      for (var target in UserRole.values) {
        expect(PermissionService.canAssignTo(UserRole.auditor, target), isFalse);
      }
      expect(PermissionService.getAssignableUsers(auditorUser, allUsers), isEmpty);
    });
  });
}
