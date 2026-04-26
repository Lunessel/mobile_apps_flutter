import 'package:mobile_app/data/models/user.dart';

abstract interface class AuthRepository {
  Future<void> register(UserModel user);
  Future<UserModel?> findByEmail(String email);
  Future<UserModel?> getCurrentUser();
  Future<void> saveCurrentUser(String email);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String email);
  Future<void> logout();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}
