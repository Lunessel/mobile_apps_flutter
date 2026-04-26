import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/repositories/secure_auth_repository.dart';

final class ServiceLocator {
  ServiceLocator._();

  static const AuthRepository auth = SecureAuthRepository(
    FlutterSecureStorage(),
  );
}
