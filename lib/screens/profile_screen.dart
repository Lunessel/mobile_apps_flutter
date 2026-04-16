import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('Іван Петренко', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'ivan@example.com',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const _InfoRow(
              label: 'Установка',
              value: 'Домашня гідропоніка',
            ),
            const Divider(),
            const _InfoRow(
              label: 'Культури',
              value: 'Базилік, Салат',
            ),
            const Divider(),
            const _InfoRow(
              label: 'Сенсори',
              value: '4 онлайн',
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Вийти',
              isOutlined: true,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
