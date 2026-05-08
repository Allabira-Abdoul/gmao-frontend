import 'package:flutter/foundation.dart';
import 'package:frontend/application/usecases/user_management_usecases.dart';
import 'package:frontend/domain/entities/user.dart';

class UserManagementState extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final GetRolesUseCase getRolesUseCase;

  List<User> _users = [];
  List<Role> _roles = [];
  bool _isLoading = false;
  String? _error;

  UserManagementState({
    required this.getUsersUseCase,
    required this.createUserUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
    required this.getRolesUseCase,
  });

  List<User> get users => _users;
  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsersAndRoles() async {
    _setLoading(true);
    try {
      // Run both requests concurrently
      final results = await Future.wait([
        getUsersUseCase.execute(),
        getRolesUseCase.execute(),
      ]);
      _users = results[0] as List<User>;
      _roles = results[1] as List<Role>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newUser = await createUserUseCase.execute(data);
      _users.add(newUser);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updatedUser = await updateUserUseCase.execute(id, data);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _setLoading(true);
    try {
      await deleteUserUseCase.execute(id);
      _users.removeWhere((u) => u.id == id);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
