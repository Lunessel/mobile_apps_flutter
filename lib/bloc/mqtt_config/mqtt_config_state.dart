import 'package:mobile_app/data/models/mqtt_config.dart';

sealed class MqttConfigState {
  const MqttConfigState();
}

final class MqttConfigNoConfig extends MqttConfigState {
  const MqttConfigNoConfig() : super();
}

final class MqttConfigLoading extends MqttConfigState {
  const MqttConfigLoading([this.config]);
  final MqttConfig? config;
}

final class MqttConfigIdle extends MqttConfigState {
  const MqttConfigIdle(this.config);
  final MqttConfig config;
}

final class MqttConfigError extends MqttConfigState {
  const MqttConfigError(this.message, [this.config]);
  final String message;
  final MqttConfig? config;
}
