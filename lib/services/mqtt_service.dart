import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;


import 'package:mobile_app/data/models/mqtt_config.dart';
import 'package:mobile_app/services/mqtt_client_native.dart'
    if (dart.library.html) 'package:mobile_app/services/mqtt_client_web.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
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
  String _topicPrefix = '';

  Stream<Map<String, String>> get data => _dataController.stream;
  Stream<bool> get connectionStatus => _connController.stream;
  bool get isConnected => _connected;

  Future<bool> connect(MqttConfig config) async {
    _topicPrefix = config.prefix;
    final id = 'hydro_flutter_${Random().nextInt(999999)}';
    _client = createMqttClient(id, config.broker, config.port);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = false;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;

    final msg = MqttConnectMessage()
        .withClientIdentifier(id)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = msg;

    try {
      await _client!.connect().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      log('MQTT connect timeout', name: 'MqttService');
      _killClient();
      return false;
    } catch (e) {
      log('MQTT connect error: $e', name: 'MqttService');
      _killClient();
      return false;
    }

    final state = _client!.connectionStatus?.state;
    log('MQTT state: $state', name: 'MqttService');

    if (state == MqttConnectionState.connected) {
      for (final topic in _topics) {
        _client!.subscribe('$_topicPrefix/$topic', MqttQos.atMostOnce);
      }
      _client!.updates?.listen(_onMessage);
      return true;
    }

    _killClient();
    return false;
  }

  /// Disconnects existing client and connects with new config.
  /// Returns true if the new connection succeeded.
  Future<bool> reconnect(MqttConfig config) async {
    _killClient();
    _connected = false;
    _connController.add(false);
    // Allow browser to fully close the previous WebSocket (CLOSING → CLOSED).
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return connect(config);
  }

  /// Silently tears down the current client without firing callbacks.
  void _killClient() {
    if (_client == null) return;
    _client!.onDisconnected = null;
    _client!.onConnected = null;
    try {
      _client!.disconnect();
    } catch (_) {}
    _client = null;
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

  void dispose() {
    _killClient();
    _dataController.close();
    _connController.close();
  }
}
