import 'package:flutter/foundation.dart';
import 'package:frontend/application/usecases/user_management_usecases.dart';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/presentation/state/auth_state.dart';

class UserManagementState extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final GetRolesUseCase getRolesUseCase;
  final AuthState authState;

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
    required this.authState,
  });

  List<User> get users => _users;
  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _token => authState.accessToken;

  Future<void> fetchUsersAndRoles() async {
    if (_token == null) return;
    _setLoading(true);
    try {
      // Run both requests concurrently
      final results = await Future.wait([
        getUsersUseCase.execute(_token!),
        getRolesUseCase.execute(_token!),
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
    if (_token == null) return false;
    _setLoading(true);
    try {
      final newUser = await createUserUseCase.execute(_token!, data);
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
    if (_token == null) return false;
    _setLoading(true);
    try {
      final updatedUser = await updateUserUseCase.execute(_token!, id, data);
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
    if (_token == null) return false;
    _setLoading(true);
    try {
      await deleteUserUseCase.execute(_token!, id);
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
