import 'package:flashlight_plugin/flashlight_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/cubits/mqtt/mqtt_cubit.dart';
import 'package:mobile_app/widgets/offline_banner.dart';
import 'package:mobile_app/widgets/sensor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _secretTapThreshold = 5;
  int _tapCount = 0;
  bool _flashlightOn = false;

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

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttCubit>().state;
    final online = context.watch<ConnectivityCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final name =
        authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
