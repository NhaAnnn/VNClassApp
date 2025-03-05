import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key, this.hintText, required this.onTap});

  final String? hintText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 18, color: Color(0xFF2F4F4F)),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm...',
        hintStyle: const TextStyle(
            color: Color(0xFF696969),
            fontSize: 16,
            fontWeight: FontWeight.w400),
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child:
              Icon(Icons.search_outlined, color: Color(0xFF1E90FF), size: 24),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD3D3D3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: onTap,
    );
  }
}
