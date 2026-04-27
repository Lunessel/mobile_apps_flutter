class MqttState {
  const MqttState({this.data = const {}, this.isConnected = false});

  final Map<String, String> data;
  final bool isConnected;

  MqttState copyWith({Map<String, String>? data, bool? isConnected}) =>
      MqttState(
        data: data ?? this.data,
        isConnected: isConnected ?? this.isConnected,
      );

  String get temperature => data['temperature'] ?? '--';
  String get humidity => data['humidity'] ?? '--';
  String get ph => data['ph'] ?? '--';
  String get light => data['light'] ?? '--';
  String get waterLevel => data['water_level'] ?? '--';
  String get nutrients => data['nutrients'] ?? '--';
}
