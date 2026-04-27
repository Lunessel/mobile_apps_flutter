import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/cubits/mqtt/mqtt_cubit.dart';
import 'package:mobile_app/widgets/offline_banner.dart';
import 'package:mobile_app/widgets/sensor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttCubit>().state;
    final online = context.watch<ConnectivityCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final name =
        authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(name.isNotEmpty ? 'Привіт, $name' : 'Hydro Monitor'),
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
              message: mqtt.isConnected ? 'MQTT підключено' : 'MQTT відключено',
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
