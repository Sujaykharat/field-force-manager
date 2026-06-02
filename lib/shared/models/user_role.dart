enum UserRole {
  admin,
  regionalManager,
  teamLead,
  fieldAgent,
  auditor;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.regionalManager:
        return 'Regional Manager';
      case UserRole.teamLead:
        return 'Team Lead';
      case UserRole.fieldAgent:
        return 'Field Agent';
      case UserRole.auditor:
        return 'Auditor';
    }
  }
}
