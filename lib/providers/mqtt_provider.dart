import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/mqtt_service.dart';

class MqttProvider extends ChangeNotifier {
  MqttProvider() {
    _dataSub = _service.data.listen((update) {
      _data.addAll(update);
      notifyListeners();
    });
    _connSub = _service.connectionStatus.listen((connected) {
      _mqttConnected = connected;
      notifyListeners();
    });
    _service.connect();
  }

  final _service = MqttService();
  late final StreamSubscription<Map<String, String>> _dataSub;
  late final StreamSubscription<bool> _connSub;

  final Map<String, String> _data = {};
  bool _mqttConnected = false;

  bool get isMqttConnected => _mqttConnected;
  String get temperature => _data['temperature'] ?? '--';
  String get humidity => _data['humidity'] ?? '--';
  String get ph => _data['ph'] ?? '--';
  String get light => _data['light'] ?? '--';
  String get waterLevel => _data['water_level'] ?? '--';
  String get nutrients => _data['nutrients'] ?? '--';

  @override
  void dispose() {
    _dataSub.cancel();
    _connSub.cancel();
    _service.disconnect();
    super.dispose();
  }
}
