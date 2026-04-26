import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/providers/connectivity_provider.dart';
import 'package:mobile_app/providers/mqtt_provider.dart';
import 'package:mobile_app/widgets/sensor_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _repo = ServiceLocator.auth;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _repo.getCurrentUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    final online = context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user != null ? 'Привіт, ${_user!.name}' : 'Hydro Monitor',
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: mqtt.isMqttConnected
                  ? 'MQTT підключено'
                  : 'MQTT відключено',
              child: Icon(
                mqtt.isMqttConnected ? Icons.sensors : Icons.sensors_off,
                size: 22,
                color: mqtt.isMqttConnected ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!online)
            Container(
              width: double.infinity,
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Text(
                'Немає з\'єднання з мережею',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
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
