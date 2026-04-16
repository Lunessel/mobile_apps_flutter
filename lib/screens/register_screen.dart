import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTextField(
                hint: "Ім'я",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              const AppTextField(
                hint: 'Підтвердіть пароль',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Створити акаунт',
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Вже є акаунт? Увійти',
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
