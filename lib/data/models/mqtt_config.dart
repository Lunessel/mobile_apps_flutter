import 'package:flutter_dotenv/flutter_dotenv.dart';

class MqttConfig {
  const MqttConfig({
    required this.broker,
    required this.port,
    required this.prefix,
  });

  final String broker;
  final int port;
  final String prefix;

  factory MqttConfig.defaults() => MqttConfig(
        broker: dotenv.env['MQTT_BROKER'] ?? 'broker.hivemq.com',
        port: int.tryParse(dotenv.env['MQTT_PORT'] ?? '') ?? 1883,
        prefix: dotenv.env['MQTT_PREFIX'] ?? 'hydroponics',
      );

  factory MqttConfig.fromJson(Map<String, dynamic> json) {
    final broker = json['broker'];
    final port = json['port'];
    final prefix = json['prefix'];

    if (broker is! String || broker.isEmpty) {
      throw const FormatException('broker має бути непорожнім рядком');
    }
    if (port is! int || port <= 0) {
      throw const FormatException('port має бути цілим позитивним числом');
    }
    if (prefix is! String || prefix.isEmpty) {
      throw const FormatException('prefix має бути непорожнім рядком');
    }

    return MqttConfig(broker: broker, port: port, prefix: prefix);
  }

  @override
  String toString() => '$broker:$port / $prefix';
}
