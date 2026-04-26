import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/alert.dart';
import 'package:mobile_app/data/repositories/alert_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/providers/connectivity_provider.dart';
import 'package:mobile_app/widgets/offline_banner.dart';
import 'package:provider/provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertRepository _repo = ServiceLocator.alerts;
  late Future<List<Alert>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання догляду'),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => _future = _repo.getAlerts()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Оновити',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!online)
            const OfflineBanner(
              message: 'Офлайн — відображено кешовані дані',
            ),
          Expanded(
            child: FutureBuilder<List<Alert>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Помилка: ${snapshot.error}'));
                }
                final alerts = snapshot.data ?? [];
                if (alerts.isEmpty) {
                  return const Center(child: Text('Немає завдань'));
                }
                return _AlertList(alerts: alerts);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList({required this.alerts});

  final List<Alert> alerts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        final a = alerts[index];
        return ListTile(
          leading: Icon(
            a.completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: a.completed ? Colors.green : Colors.grey,
          ),
          title: Text(
            a.title,
            style: TextStyle(
              decoration:
                  a.completed ? TextDecoration.lineThrough : null,
              color: a.completed ? Colors.grey : null,
            ),
          ),
          subtitle: Text('Завдання #${a.id}'),
        );
      },
    );
  }
}
