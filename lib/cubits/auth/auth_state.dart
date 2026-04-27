import 'package:mobile_app/data/models/user.dart';

sealed class AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);
  final UserModel user;
}

final class AuthUnauthenticated extends AuthState {}

final class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}
