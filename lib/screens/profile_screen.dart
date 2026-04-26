import 'package:flutter/material.dart';
import 'package:mobile_app/data/repositories/auth_repository.dart';
import 'package:mobile_app/data/service_locator.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _repo = ServiceLocator.auth;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _repo.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = user?.name ?? '';
      _email = user?.email;
    });
  }

  Future<void> _save() async {
    final nameErr = AuthValidator.name(_nameCtrl.text.trim());
    final passErr = _passCtrl.text.isEmpty
        ? null
        : AuthValidator.password(_passCtrl.text);
    if (nameErr != null || passErr != null) {
      setState(() => _message = nameErr ?? passErr);
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    final current = await _repo.getCurrentUser();
    if (!mounted || current == null) return;
    final newPass = _passCtrl.text.isEmpty ? null : _passCtrl.text;
    final updated = current.copyWith(
      name: _nameCtrl.text.trim(),
      password: newPass,
    );
    await _repo.updateUser(updated);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = 'Збережено';
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити акаунт?'),
        content: const Text('Цю дію неможливо скасувати.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Видалити',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (_email == null) return;
    await _repo.deleteUser(_email!);
    if (!mounted) return;
    await Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> _logout() async {
    await _repo.logout();
    if (!mounted) return;
    await Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

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
              radius: 40,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(_email ?? '', style: textTheme.bodyMedium),
            const SizedBox(height: 24),
            AppTextField(
              hint: "Ім'я",
              icon: Icons.person_outline,
              controller: _nameCtrl,
            ),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Новий пароль (залиште порожнім щоб не змінювати)',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _passCtrl,
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                style: TextStyle(
                  color: _message == 'Збережено'
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: _loading ? 'Збереження...' : 'Зберегти зміни',
              onPressed: _loading ? null : _save,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Вийти',
              isOutlined: true,
              onPressed: _logout,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Видалити акаунт',
              isOutlined: true,
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}
