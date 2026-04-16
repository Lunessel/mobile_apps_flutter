import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/sensor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydro Monitor'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
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
    );
  }
}
