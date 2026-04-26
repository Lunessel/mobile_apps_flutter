import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient(String clientId) {
  final client = MqttServerClient('broker.hivemq.com', clientId);
  client.port = 1883;
  return client;
}
