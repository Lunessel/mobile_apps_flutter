import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthLoading()) {
    _loadCurrentUser();
  }

  AuthCubit.unauthenticated(this._repo) : super(AuthUnauthenticated());

  final AuthRepository _repo;

  Future<void> _loadCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final user = await _repo.getCurrentUser();
    emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final user = await _repo.findByEmail(email);
    if (user == null || user.password != password) {
      emit(AuthError('Невірний email або пароль'));
      return;
    }
    await _repo.saveCurrentUser(email);
    await _repo.saveToken(_generateToken());
    emit(AuthAuthenticated(user));
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());
    final existing = await _repo.findByEmail(user.email);
    if (existing != null) {
      emit(AuthError('Користувач з таким email вже існує'));
      return;
    }
    await _repo.register(user);
    await _repo.saveCurrentUser(user.email);
    emit(AuthAuthenticated(user));
  }

  Future<void> updateUser(UserModel updated) async {
    await _repo.updateUser(updated);
    emit(AuthAuthenticated(updated));
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> deleteUser(String email) async {
    await _repo.deleteUser(email);
    emit(AuthUnauthenticated());
  }

  static String _generateToken() => List.generate(
        16,
        (_) =>
            Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
}
