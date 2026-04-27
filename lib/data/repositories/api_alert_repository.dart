import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/data/models/alert.dart';
import 'package:mobile_app/data/repositories/alert_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAlertRepository implements AlertRepository {
  ApiAlertRepository(this._storage) {
    _dio = _buildDio();
  }

  final FlutterSecureStorage _storage;
  late final Dio _dio;

  static const _cacheKey = 'cached_alerts';
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  @override
  Future<List<Alert>> getAlerts() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/todos',
        queryParameters: {'_limit': 20},
      );
      final alerts = (response.data ?? [])
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheAlerts(alerts);
      return alerts;
    } on DioException {
      return _loadCache();
    }
  }

  Future<void> _cacheAlerts(List<Alert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(alerts.map((a) => a.toJson()).toList()),
    );
  }

  Future<List<Alert>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Alert.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
