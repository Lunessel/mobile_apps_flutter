import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/widgets/sensor_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_user != null ? 'Привіт, ${_user!.name}' : 'Hydro Monitor'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
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
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  SensorCard(
                    title: 'Температура',
                    value: '22.5',
                    unit: '°C',
                    icon: Icons.thermostat,
                    color: Colors.orange,
                  ),
                  SensorCard(
                    title: 'Вологість',
                    value: '68',
                    unit: '%',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  SensorCard(
                    title: 'Рівень pH',
                    value: '6.2',
                    unit: 'pH',
                    icon: Icons.science,
                    color: Colors.purple,
                  ),
                  SensorCard(
                    title: 'Освітлення',
                    value: '4200',
                    unit: 'lux',
                    icon: Icons.wb_sunny,
                    color: Colors.amber,
                  ),
                  SensorCard(
                    title: 'Рівень води',
                    value: '85',
                    unit: '%',
                    icon: Icons.opacity,
                    color: Colors.teal,
                  ),
                  SensorCard(
                    title: 'Поживні речовини',
                    value: '1.8',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/profile'),
        tooltip: 'Профіль',
        child: const Icon(Icons.person_outline),
      ),
    );
  }
}
