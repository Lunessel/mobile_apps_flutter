import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hint,
    this.controller,
    this.icon,
    this.obscureText = false,
    this.errorText,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
