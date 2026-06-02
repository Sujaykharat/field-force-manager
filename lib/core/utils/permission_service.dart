import '../../shared/models/user_role.dart';
import '../../shared/models/user_model.dart';

class PermissionService {
  static bool canCreateTask(UserRole role) {
    return role == UserRole.admin || 
           role == UserRole.regionalManager || 
           role == UserRole.teamLead;
  }

  static bool canAssignTask(UserRole role) {
    return role == UserRole.admin || 
           role == UserRole.regionalManager || 
           role == UserRole.teamLead;
  }

  static bool canAssignTo(UserRole currentRole, UserRole targetRole, {String? currentUserId, String? targetUserId}) {
    switch (currentRole) {
      case UserRole.admin:
        return true;
      case UserRole.regionalManager:
        return targetRole == UserRole.teamLead || targetRole == UserRole.fieldAgent;
      case UserRole.teamLead:
        // Cannot assign to self or higher roles
        if (currentUserId != null && targetUserId != null && currentUserId == targetUserId) {
          return false;
        }
        return targetRole == UserRole.fieldAgent;
      case UserRole.fieldAgent:
      case UserRole.auditor:
        return false;
    }
  }

  static List<UserModel> getAssignableUsers(UserModel currentUser, List<UserModel> allUsers) {
    return allUsers.where((user) => canAssignTo(
      currentUser.role, 
      user.role, 
      currentUserId: currentUser.id, 
      targetUserId: user.id,
    )).toList();
  }

  static bool canEditTask(UserRole role) {
    return role == UserRole.admin || 
           role == UserRole.regionalManager || 
           role == UserRole.teamLead;
  }

  static bool canUpdateVisit(UserRole role) {
    return role == UserRole.fieldAgent || role == UserRole.admin;
  }

  static bool canChangeStatus(UserRole role) {
    return role == UserRole.fieldAgent || role == UserRole.admin || role == UserRole.teamLead;
  }

  static bool isReadOnly(UserRole role) {
    return role == UserRole.auditor;
  }
}

class UnauthorizedAssignmentException implements Exception {
  final String message;
  UnauthorizedAssignmentException(this.message);
  @override
  String toString() => 'UnauthorizedAssignmentException: $message';
}
