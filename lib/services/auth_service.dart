import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user.dart';

class AuthUser {
  final String username;
  final String email;

  const AuthUser({required this.username, required this.email});
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _usersKey = 'auth_users';
  static const _currentUserKey = 'auth_current_user';

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _currentUser = AuthUser(
      username: decoded['username'] as String,
      email: decoded['email'] as String,
    );
  }

  Future<void> _saveCurrentUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey,
      jsonEncode({'username': user.username, 'email': user.email}),
    );
  }

  Future<void> _clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }

  Future<List<AppUser>> _loadUsers() async {
    return DatabaseHelper.instance.getUsers();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final exists = users.any(
      (user) => user.username == username || user.email == email,
    );
    if (exists) return false;

    final user = AppUser(username: username, email: email, password: password);
    await DatabaseHelper.instance.insertUser(user);
    _currentUser = AuthUser(username: username, email: email);
    await _saveCurrentUser(_currentUser!);
    return true;
  }

  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    await _loadCurrentUser();
    final users = await _loadUsers();
    final match = users.where((user) {
      return (user.username == usernameOrEmail ||
              user.email == usernameOrEmail) &&
          user.password == password;
    }).toList();

    if (match.isEmpty) {
      return false;
    }

    final user = match.first;
    _currentUser = AuthUser(username: user.username, email: user.email);
    await _saveCurrentUser(_currentUser!);
    return true;
  }

  Future<bool> forgotPassword({
    required String usernameOrEmail,
    required String newPassword,
  }) async {
    final users = await _loadUsers();
    final match = users
        .where(
          (user) =>
              user.username == usernameOrEmail || user.email == usernameOrEmail,
        )
        .toList();
    if (match.isEmpty) return false;

    final user = match.first;
    await DatabaseHelper.instance.updateUser(
      AppUser(
        id: user.id,
        username: user.username,
        email: user.email,
        password: newPassword,
      ),
    );
    return true;
  }

  Future<void> logout() async {
    await _clearCurrentUser();
  }

  Future<void> clearForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await DatabaseHelper.instance.clearUsers();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }
}
