import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/auth/auth_cubit.dart';
import 'package:mobile_app/cubits/auth/auth_state.dart';
import 'package:mobile_app/domain/auth_validator.dart';
import 'package:mobile_app/widgets/app_button.dart';
import 'package:mobile_app/widgets/app_text_field.dart';
import 'package:mobile_app/widgets/confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      _nameCtrl.text = state.user.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final nameErr = AuthValidator.name(_nameCtrl.text.trim());
    final passErr = _passCtrl.text.isEmpty
        ? null
        : AuthValidator.password(_passCtrl.text);
    if (nameErr != null || passErr != null) {
      setState(() => _message = nameErr ?? passErr);
      return;
    }
    final state = context.read<AuthCubit>().state;
    if (state is! AuthAuthenticated) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    context.read<AuthCubit>().updateUser(
          state.user.copyWith(
            name: _nameCtrl.text.trim(),
            password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
          ),
        );
  }

  Future<void> _logout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Вийти з акаунту?',
      content: 'Ви впевнені, що хочете вийти?',
      confirmLabel: 'Вийти',
    );
    if (!ok || !mounted) return;
    context.read<AuthCubit>().logout();
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Видалити акаунт?',
      content: 'Цю дію неможливо скасувати.',
      confirmLabel: 'Видалити',
    );
    if (!ok || !mounted) return;
    final state = context.read<AuthCubit>().state;
    if (state is! AuthAuthenticated) return;
    context.read<AuthCubit>().deleteUser(state.user.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else if (state is AuthAuthenticated && _saving) {
          _saving = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Збережено')),
          );
        } else if (state is AuthError) {
          setState(() => _message = state.message);
        }
      },
      builder: (context, state) {
        final email =
            state is AuthAuthenticated ? state.user.email : '';
        final loading = state is AuthLoading;
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
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
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
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: loading ? 'Збереження...' : 'Зберегти зміни',
                  onPressed: loading ? null : _save,
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
                  onPressed: _delete,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
