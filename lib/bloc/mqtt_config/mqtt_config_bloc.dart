import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_event.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_state.dart';
import 'package:mobile_app/data/models/mqtt_config.dart';
import 'package:mobile_app/services/mqtt_service.dart';

class MqttConfigBloc extends Bloc<MqttConfigEvent, MqttConfigState> {
  MqttConfigBloc(this._mqttService, this._defaultConfig)
      : super(const MqttConfigNoConfig()) {
    on<MqttConfigPickFileRequested>(_onPickFile);
    on<MqttConfigResetRequested>(_onReset);
  }

  final MqttService _mqttService;
  final MqttConfig _defaultConfig;

  MqttConfig? _currentConfig(MqttConfigState s) => switch (s) {
        MqttConfigIdle(:final config) => config,
        MqttConfigLoading(:final config) => config,
        MqttConfigError(:final config) => config,
        MqttConfigNoConfig() => null,
      };

  Future<void> _onPickFile(
    MqttConfigPickFileRequested event,
    Emitter<MqttConfigState> emit,
  ) async {
    final previous = _currentConfig(state);
    emit(MqttConfigLoading(previous));

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
    } catch (_) {
      emit(MqttConfigError(
        'Не вдалося відкрити файловий менеджер',
        previous,
      ));
      return;
    }

    if (result == null || result.files.isEmpty) {
      emit(previous != null
          ? MqttConfigIdle(previous)
          : const MqttConfigNoConfig());
      return;
    }

    final file = result.files.first;
    final fileName = file.name;
    String content;
    try {
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        emit(MqttConfigError('Не вдалося прочитати файл', previous));
        return;
      }
    } catch (_) {
      emit(MqttConfigError('Помилка читання файлу', previous));
      return;
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      emit(MqttConfigError('Невірний формат JSON', previous));
      return;
    }

    MqttConfig config;
    try {
      config = MqttConfig.fromJson(json);
    } on FormatException catch (e) {
      emit(MqttConfigError('Невалідний конфіг: ${e.message}', previous));
      return;
    }

    final connected = await _mqttService.reconnect(config);
    if (connected) {
      emit(MqttConfigIdle(config));
    } else {
      emit(MqttConfigError(
        'Немає з\'єднання з брокером\n'
        '${config.broker}:${config.port}\n'
        'Файл: $fileName',
        previous,
      ));
    }
  }

  Future<void> _onReset(
    MqttConfigResetRequested event,
    Emitter<MqttConfigState> emit,
  ) async {
    emit(MqttConfigLoading(_currentConfig(state)));
    final connected = await _mqttService.reconnect(_defaultConfig);
    if (connected) {
      emit(MqttConfigIdle(_defaultConfig));
    } else {
      emit(MqttConfigError(
        'Немає з\'єднання з брокером\n'
        '${_defaultConfig.broker}:${_defaultConfig.port}',
      ));
    }
  }
}
