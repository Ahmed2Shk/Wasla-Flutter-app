import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final int maxLines;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
