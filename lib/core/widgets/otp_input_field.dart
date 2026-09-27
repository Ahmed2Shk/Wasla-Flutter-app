import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// حقل إدخال رمز OTP/PIN — عدد صناديق قابل للتخصيص (6 لـ OTP، 4 لـ PIN)
class SegmentedCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final bool obscure;

  const SegmentedCodeInput({
    required this.length,
    required this.onCompleted,
    this.obscure = false,
    super.key,
  });

  @override
  State<SegmentedCodeInput> createState() => _SegmentedCodeInputState();
}

class _SegmentedCodeInputState extends State<SegmentedCodeInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 46,
          height: 54,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            obscureText: widget.obscure,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (v) => _onChanged(index, v),
          ),
        );
      }),
    );
  }
}
