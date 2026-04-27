import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/cubits/connectivity/connectivity_cubit.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';
import 'package:mobile_app/widgets/offline_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    final emailErr = AuthValidator.email(_emailCtrl.text.trim());
    final passErr = AuthValidator.password(_passCtrl.text);
    if (emailErr != null || passErr != null) {
      setState(() => _error = emailErr ?? passErr);
      return;
    }
    setState(() => _error = null);
    context
        .read<AuthCubit>()
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final online = context.watch<ConnectivityCubit>().state;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else if (state is AuthError) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Smart Hydroponics Monitoring',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
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
                    label: loading ? 'Завантаження...' : 'Увійти',
                    onPressed: loading ? null : _login,
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
      },
    );
  }
}
