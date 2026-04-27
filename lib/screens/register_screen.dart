import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _register() {
    final firstErr = AuthValidator.name(_nameCtrl.text.trim()) ??
        AuthValidator.email(_emailCtrl.text.trim()) ??
        AuthValidator.password(_passCtrl.text) ??
        AuthValidator.confirmPassword(_passCtrl.text, _confirmCtrl.text);
    if (firstErr != null) {
      setState(() => _error = firstErr);
      return;
    }
    setState(() => _error = null);
    context.read<AuthCubit>().register(
          UserModel(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  AppTextField(
                    hint: "Ім'я",
                    icon: Icons.person_outline,
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: 'Підтвердіть пароль',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _confirmCtrl,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label:
                        loading ? 'Завантаження...' : 'Створити акаунт',
                    onPressed: loading ? null : _register,
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
      },
    );
  }
}
