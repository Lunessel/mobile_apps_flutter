import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

// HiveMQ public broker WebSocket endpoint: ws://<broker>:8000/mqtt
// Native TCP port (1883) ≠ WebSocket port (8000) — port param is ignored here.
MqttClient createMqttClient(String clientId, String broker, int port) {
  final client = MqttBrowserClient('ws://$broker/mqtt', clientId);
  client.port = 8000;
  return client;
}
