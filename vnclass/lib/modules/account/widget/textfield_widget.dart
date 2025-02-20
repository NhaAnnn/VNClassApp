import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    this.controller,
    required this.labelText,
    this.obscureText = false, // cho mật khẩu
    this.onChanged, // callback khi giá trị thay đổi
    this.enabled = true, // thêm tham số enabled (mặc định là true)
  });

  final TextEditingController? controller;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled, // kiểm soát trạng thái chỉnh sửa
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ColorApp.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 29, 92, 252), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorApp.primaryColor, width: 2.0),
        ),
      ),
    );
  }
}
