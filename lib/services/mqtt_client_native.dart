import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient(String clientId, String broker, int port) {
  final client = MqttServerClient(broker, clientId);
  client.port = port;
  return client;
}
