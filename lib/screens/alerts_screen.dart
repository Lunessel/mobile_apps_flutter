import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/alerts/alerts_cubit.dart';
import 'package:mobile_app/cubits/alerts/alerts_state.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/data/models/alert.dart';
import 'package:mobile_app/widgets/offline_banner.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання догляду'),
        actions: [
          IconButton(
            onPressed: () => context.read<AlertsCubit>().loadAlerts(),
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
            child: BlocBuilder<AlertsCubit, AlertsState>(
              builder: (context, state) {
                if (state is AlertsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AlertsError) {
                  return Center(child: Text('Помилка: ${state.message}'));
                }
                final alerts =
                    state is AlertsLoaded ? state.alerts : <Alert>[];
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
