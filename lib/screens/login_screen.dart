import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/providers/connectivity_provider.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';
import 'package:mobile_app/widgets/offline_banner.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _repo = ServiceLocator.auth;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailErr = AuthValidator.email(_emailCtrl.text.trim());
    final passErr = AuthValidator.password(_passCtrl.text);
    if (emailErr != null || passErr != null) {
      setState(() => _error = emailErr ?? passErr);
      return;
    }

    final online = await context.read<ConnectivityProvider>().check();
    if (!mounted) return;
    if (!online) {
      setState(() => _error = 'Немає з\'єднання з мережею');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await _repo.findByEmail(_emailCtrl.text.trim());
    if (!mounted) return;
    if (user == null || user.password != _passCtrl.text) {
      setState(() {
        _loading = false;
        _error = 'Невірний email або пароль';
      });
      return;
    }
    await _repo.saveCurrentUser(user.email);
    await _repo.saveToken(
      List.generate(
        16,
        (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    await Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final online = context.watch<ConnectivityProvider>().isOnline;

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
              if (!online) const OfflineBanner(),
              SizedBox(height: size.height * 0.06),
              AppTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
              ),
              const SizedBox(height: 16),
              AppTextField(
                hint: 'Пароль',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: _passCtrl,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: _loading ? 'Завантаження...' : 'Увійти',
                onPressed: _loading ? null : _login,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Зареєструватися',
                isOutlined: true,
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
