import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:mobile_app/services/mqtt_client_native.dart'
    if (dart.library.html) 'package:mobile_app/services/mqtt_client_web.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  static const _topicPrefix = 'hydroponics';
  static const _topics = [
    'temperature',
    'humidity',
    'ph',
    'light',
    'water_level',
    'nutrients',
  ];

  MqttClient? _client;
  final _dataController = StreamController<Map<String, String>>.broadcast();
  final _connController = StreamController<bool>.broadcast();
  bool _connected = false;

  Stream<Map<String, String>> get data => _dataController.stream;
  Stream<bool> get connectionStatus => _connController.stream;
  bool get isConnected => _connected;

  Future<void> connect() async {
    final id = 'hydro_flutter_${Random().nextInt(999999)}';
    _client = createMqttClient(id);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;

    final msg = MqttConnectMessage()
        .withClientIdentifier(id)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = msg;

    try {
      await _client!.connect();
    } catch (e) {
      log('MQTT connect error: $e', name: 'MqttService');
      _client!.disconnect();
      return;
    }

    final state = _client!.connectionStatus?.state;
    log('MQTT state: $state', name: 'MqttService');

    if (state == MqttConnectionState.connected) {
      for (final topic in _topics) {
        _client!.subscribe('$_topicPrefix/$topic', MqttQos.atMostOnce);
      }
      _client!.updates?.listen(_onMessage);
    }
  }

  void _onConnected() {
    _connected = true;
    _connController.add(true);
  }

  void _onDisconnected() {
    _connected = false;
    _connController.add(false);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final pub = msg.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        pub.payload.message,
      );
      final topic = msg.topic.replaceFirst('$_topicPrefix/', '');
      _dataController.add({topic: payload});
    }
  }

  void disconnect() {
    _client?.disconnect();
    _dataController.close();
    _connController.close();
  }
}
