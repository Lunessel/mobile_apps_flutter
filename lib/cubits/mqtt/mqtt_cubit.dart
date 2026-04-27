import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/mqtt/mqtt_state.dart';
import 'package:mobile_app/services/mqtt_service.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit(this._service) : super(const MqttState()) {
    _dataSub = _service.data.listen(
      (d) => emit(state.copyWith(data: {...state.data, ...d})),
    );
    _statusSub = _service.connectionStatus.listen((connected) {
      if (!connected) {
        emit(state.copyWith(isConnected: false, data: {}));
      } else {
        emit(state.copyWith(isConnected: true));
      }
    });
  }

  final MqttService _service;
  StreamSubscription<Map<String, String>>? _dataSub;
  StreamSubscription<bool>? _statusSub;

  @override
  Future<void> close() async {
    await _dataSub?.cancel();
    await _statusSub?.cancel();
    _service.dispose();
    return super.close();
  }
}
