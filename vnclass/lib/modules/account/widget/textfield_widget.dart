import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    this.controller,
    required this.labelText,
    this.obscureText = false,
    this.onChanged,
    this.enabled = true,
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  });

  final TextEditingController? controller;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
      style: textStyle, // Áp dụng kiểu chữ tùy chỉnh
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color:
              Colors.grey.shade600, // Nhẹ nhàng hơn khi label ở trạng thái nghỉ
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: enabled
              ? const Color(0xFF1976D2)
              : Colors.grey.shade400, // Màu khi focus
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        filled: true, // Thêm nền nhẹ
        fillColor: enabled
            ? Colors.white
            : Colors.grey.shade100, // Nền thay đổi theo enabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Bo góc mềm mại hơn
          borderSide: BorderSide.none, // Loại bỏ viền mặc định
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300, // Viền nhạt khi không focus
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1976D2), // Xanh đậm khi focus
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade200, // Viền mờ hơn khi disabled
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
