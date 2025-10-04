import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,
    required this.controller,
    required this.textInputType,
    required this.hintText
  });

  final TextEditingController controller;
  final TextInputType textInputType;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.lightGreen2),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.lightGray1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.green1),
        ),
        hintText: hintText,
        hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.lightGray1),
      ),
    );
  }
}
