import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    this.controller,
    required this.labelText,
    this.obscureText = false, // Thêm tùy chọn cho mật khẩu
    this.onChanged, // Thêm callback onChanged
  });

  final TextEditingController? controller;
  final String labelText;
  final bool obscureText; // Thêm thuộc tính cho mật khẩu
  final ValueChanged<String>? onChanged; // Callback khi giá trị thay đổi

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, // Dùng cho mật khẩu
      onChanged: onChanged, // Gọi callback khi giá trị thay đổi
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ColorApp.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 29, 92, 252), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorApp.primaryColor, width: 2.0),
        ),
      ),
    );
  }
}
