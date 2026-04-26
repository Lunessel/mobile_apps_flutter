import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/user.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthRepository _repo = ServiceLocator.auth;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nameErr = AuthValidator.name(_nameCtrl.text.trim());
    final emailErr = AuthValidator.email(_emailCtrl.text.trim());
    final passErr = AuthValidator.password(_passCtrl.text);
    final confirmErr = AuthValidator.confirmPassword(
      _passCtrl.text,
      _confirmCtrl.text,
    );
    final firstErr = nameErr ?? emailErr ?? passErr ?? confirmErr;
    if (firstErr != null) {
      setState(() => _error = firstErr);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final existing = await _repo.findByEmail(_emailCtrl.text.trim());
    if (!mounted) return;
    if (existing != null) {
      setState(() {
        _loading = false;
        _error = 'Користувач з таким email вже існує';
      });
      return;
    }
    final user = UserModel(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    await _repo.register(user);
    await _repo.saveCurrentUser(user.email);
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
                label: _loading ? 'Завантаження...' : 'Створити акаунт',
                onPressed: _loading ? null : _register,
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
