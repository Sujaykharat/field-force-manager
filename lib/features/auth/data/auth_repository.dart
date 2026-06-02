import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/user_role.dart';

class AuthRepository {
  final _box = Hive.box('auth');
  
  final List<UserModel> _mockUsers = [
    UserModel(id: '1', email: 'admin@test.com', name: 'System Admin', role: UserRole.admin),
    UserModel(id: '2', email: 'manager@test.com', name: 'John Manager', role: UserRole.regionalManager),
    UserModel(id: '3', email: 'lead@test.com', name: 'Sarah Lead', role: UserRole.teamLead),
    UserModel(id: '4', email: 'agent@test.com', name: 'Mike Agent', role: UserRole.fieldAgent),
    UserModel(id: '5', email: 'auditor@test.com', name: 'Alex Auditor', role: UserRole.auditor),
  ];

  Future<UserModel?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (password != '123456') {
      throw Exception('Invalid password');
    }

    try {
      final user = _mockUsers.firstWhere((user) => user.email == email);
      // Persist logged in user
      await _box.put('current_user', user.toJson());
      return user;
    } catch (e) {
      throw Exception('User not found');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final userData = _box.get('current_user');
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _box.delete('current_user');
  }

  Future<List<UserModel>> getAllUsers() async {
    return _mockUsers;
  }
}
