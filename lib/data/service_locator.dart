import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/data/repositories/alert_repository.dart';
import 'package:mobile_app/data/repositories/api_alert_repository.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/repositories/secure_auth_repository.dart';
import 'package:mobile_app/services/connectivity_service.dart';
import 'package:mobile_app/services/mqtt_service.dart';

final class ServiceLocator {
  ServiceLocator._();

  static const _storage = FlutterSecureStorage();
  static const AuthRepository auth = SecureAuthRepository(_storage);
  static final AlertRepository alerts = ApiAlertRepository(_storage);
  static final ConnectivityService connectivity = ConnectivityService();
  static final MqttService mqtt = MqttService();
}
