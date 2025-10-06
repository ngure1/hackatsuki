import 'package:flutter/material.dart';

import 'package:mobile/theme.dart';

class PasswordTextFieldWidget extends StatelessWidget {
  const PasswordTextFieldWidget({
    super.key,

    required this.controller,
    this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final IconData prefixIcon;
  final bool? obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText != null ? obscureText! : false,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.green2),
        ),
        floatingLabelStyle: AppTheme.labelMedium.copyWith(
          color: AppTheme.green2,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
