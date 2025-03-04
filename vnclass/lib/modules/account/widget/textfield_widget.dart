import 'package:flutter/material.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    this.controller,
    required this.labelText,
    this.obscureText = false,
    this.onChanged,
    this.onTap, // Thêm tham số onTap
    this.enabled = true,
    this.errorText,
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  });

  final TextEditingController? controller;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap; // Thêm kiểu VoidCallback
  final bool enabled;
  final TextStyle? textStyle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          onTap: onTap, // Gọi hàm onTap khi nhấn vào
          enabled: enabled,
          style: textStyle,
          decoration: InputDecoration(
            labelText: labelText,
            errorText: null, // Bỏ qua errorText ở đây
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? const Color(0xFF1976D2) : Colors.grey.shade400,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
            ),
          ),
        ),
        // Hiển thị thông báo lỗi bên dưới
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
