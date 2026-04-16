import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: size.height * 0.08),
              const Icon(Icons.grass, size: 64, color: Colors.teal),
              const SizedBox(height: 16),
              Text(
                'Hydro Monitor',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Hydroponics Monitoring',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              SizedBox(height: size.height * 0.06),
              const AppTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                hint: 'Пароль',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Увійти',
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Зареєструватися',
                isOutlined: true,
                onPressed: () =>
                    Navigator.pushNamed(context, '/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
