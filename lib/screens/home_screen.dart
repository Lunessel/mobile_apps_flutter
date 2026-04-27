import 'package:flashlight_plugin/flashlight_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_bloc.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_event.dart';
import 'package:mobile_app/bloc/mqtt_config/mqtt_config_state.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/cubits/mqtt/mqtt_cubit.dart';
import 'package:mobile_app/widgets/offline_banner.dart';
import 'package:mobile_app/widgets/sensor_card.dart';
import 'package:shake/shake.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _secretTapThreshold = 5;
  int _tapCount = 0;
  bool _flashlightOn = false;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(onPhoneShake: _onShake);
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  void _onShake(ShakeEvent _) {
    if (!mounted) return;
    context.read<MqttConfigBloc>().add(MqttConfigResetRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Скидаємо до дефолтного конфігу...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onTitleTap() {
    _tapCount++;
    if (_tapCount >= _secretTapThreshold) {
      _tapCount = 0;
      _showFlashlightSheet();
    }
  }

  void _showFlashlightSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _FlashlightSheet(
        isOn: _flashlightOn,
        onStateChange: (value) => setState(() => _flashlightOn = value),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Помилка конфігурації'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttCubit>().state;
    final online = context.watch<ConnectivityCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final name =
        authState is AuthAuthenticated ? authState.user.name : '';

    return BlocListener<MqttConfigBloc, MqttConfigState>(
      listener: (context, state) {
        if (state is MqttConfigError) {
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: _onTitleTap,
            child: Text(
              name.isNotEmpty ? 'Привіт, $name' : 'Hydro Monitor',
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/alerts'),
              icon: const Icon(Icons.task_alt),
              tooltip: 'Завдання',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: mqtt.isConnected
                    ? 'MQTT підключено'
                    : 'MQTT відключено',
                child: Icon(
                  mqtt.isConnected ? Icons.sensors : Icons.sensors_off,
                  size: 22,
                  color: mqtt.isConnected ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (!online) const OfflineBanner(),
            const _MqttConfigPanel(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Показники системи',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.extent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          SensorCard(
                            title: 'Температура',
                            value: mqtt.temperature,
                            unit: '°C',
                            icon: Icons.thermostat,
                            color: Colors.orange,
                          ),
                          SensorCard(
                            title: 'Вологість',
                            value: mqtt.humidity,
                            unit: '%',
                            icon: Icons.water_drop,
                            color: Colors.blue,
                          ),
                          SensorCard(
                            title: 'Рівень pH',
                            value: mqtt.ph,
                            unit: 'pH',
                            icon: Icons.science,
                            color: Colors.purple,
                          ),
                          SensorCard(
                            title: 'Освітлення',
                            value: mqtt.light,
                            unit: 'lux',
                            icon: Icons.wb_sunny,
                            color: Colors.amber,
                          ),
                          SensorCard(
                            title: 'Рівень води',
                            value: mqtt.waterLevel,
                            unit: '%',
                            icon: Icons.opacity,
                            color: Colors.teal,
                          ),
                          SensorCard(
                            title: 'Поживні речовини',
                            value: mqtt.nutrients,
                            unit: 'EC',
                            icon: Icons.eco,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'Профіль',
          child: const Icon(Icons.person_outline),
        ),
      ),
    );
  }
}

class _MqttConfigPanel extends StatelessWidget {
  const _MqttConfigPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MqttConfigBloc, MqttConfigState>(
      builder: (context, state) {
        final isLoading = state is MqttConfigLoading;
        final noConfig = state is MqttConfigNoConfig;

        final config = switch (state) {
          MqttConfigIdle(:final config) => config,
          MqttConfigLoading(:final config) => config,
          MqttConfigError(:final config) => config,
          MqttConfigNoConfig() => null,
        };

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_ethernet,
                        size: 16,
                        color: config != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: config != null
                            ? Text(
                                '${config.broker}:${config.port}'
                                '  •  ${config.prefix}',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                'Конфіг не завантажено',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.orange),
                              ),
                      ),
                      const SizedBox(width: 8),
                      if (isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: () => context
                              .read<MqttConfigBloc>()
                              .add(MqttConfigPickFileRequested()),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Конфіг'),
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (noConfig)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Завантажте JSON файл або потрясіть телефон '
                    'для підключення',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlashlightSheet extends StatefulWidget {
  const _FlashlightSheet({
    required this.isOn,
    required this.onStateChange,
  });

  final bool isOn;
  final void Function(bool) onStateChange;

  @override
  State<_FlashlightSheet> createState() => _FlashlightSheetState();
}

class _FlashlightSheetState extends State<_FlashlightSheet> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.isOn;
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      await FlashlightPlugin.onLight(context);
    } else {
      await FlashlightPlugin.offLight(context);
    }
    if (!mounted) return;
    setState(() => _isOn = value);
    widget.onStateChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isOn ? Icons.flashlight_on : Icons.flashlight_off,
              size: 56,
              color: _isOn ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _isOn ? 'Ліхтарик увімкнено' : 'Ліхтарик вимкнено',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isOn ? null : () => _toggle(true),
                  icon: const Icon(Icons.flashlight_on),
                  label: const Text('Увімкнути'),
                ),
                ElevatedButton.icon(
                  onPressed: _isOn ? () => _toggle(false) : null,
                  icon: const Icon(Icons.flashlight_off),
                  label: const Text('Вимкнути'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
