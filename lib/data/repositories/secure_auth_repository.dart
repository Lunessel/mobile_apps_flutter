import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';

class SecureAuthRepository implements AuthRepository {
  const SecureAuthRepository(this._storage);

  final FlutterSecureStorage _storage;

  static const _currentKey = 'current_user';

  static String _userKey(String email) => 'user_$email';

  @override
  Future<void> register(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _storage.write(key: _userKey(user.email), value: json);
  }

  @override
  Future<UserModel?> findByEmail(String email) async {
    final raw = await _storage.read(key: _userKey(email));
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final email = await _storage.read(key: _currentKey);
    if (email == null) return null;
    return findByEmail(email);
  }

  @override
  Future<void> saveCurrentUser(String email) =>
      _storage.write(key: _currentKey, value: email);

  @override
  Future<void> updateUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _storage.write(key: _userKey(user.email), value: json);
  }

  @override
  Future<void> deleteUser(String email) async {
    await _storage.delete(key: _userKey(email));
    await logout();
  }

  @override
  Future<void> logout() => _storage.delete(key: _currentKey);
}
