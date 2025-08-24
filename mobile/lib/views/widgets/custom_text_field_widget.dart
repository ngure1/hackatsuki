import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

class CustomTextFieldWidget extends StatefulWidget {
  const CustomTextFieldWidget({
    super.key,
    required this.liveSearch,
    this.onSearch,
    this.hinttext
  });

  final bool liveSearch;
  final ValueChanged<String>? onSearch;
  final String? hinttext;

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _handleChanged(String enteredValue) {
    if (!widget.liveSearch) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onSearch!(enteredValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      onSubmitted: widget.liveSearch ? null : widget.onSearch,
      decoration: InputDecoration(
        hintText: widget.hinttext,
        hintStyle: AppTheme.labelMedium.copyWith(color: AppTheme.gray2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.green2, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.textGray, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
