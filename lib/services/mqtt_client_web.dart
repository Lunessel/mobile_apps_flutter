import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

// HiveMQ WebSocket requires /mqtt path: ws://broker.hivemq.com:8000/mqtt
// uri.replace(port: X) preserves the path, so pass /mqtt in the server URL
MqttClient createMqttClient(String clientId) {
  final client = MqttBrowserClient('ws://broker.hivemq.com/mqtt', clientId);
  client.port = 8000;
  return client;
}
