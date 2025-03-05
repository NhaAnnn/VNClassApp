import 'package:flutter/material.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    this.controller,
    required this.labelText,
    this.obscureText = false,
    this.onChanged,
    this.onTap, // Optional onTap callback
    this.enabled = true,
    this.errorText,
    this.colorBorder,
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  });

  final TextEditingController? controller;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap; // Optional onTap callback
  final bool enabled;
  final TextStyle? textStyle;
  final String? errorText;
  final Color? colorBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          onTap: onTap, // Call onTap when tapped
          enabled: enabled,
          style: textStyle,
          decoration: InputDecoration(
            labelText: labelText,
            errorText: null, // Can be used for validation
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
                color: colorBorder ?? Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFF1976D2), // Use provided color or default
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorBorder ?? Colors.grey.shade200,
                width: 1.5,
              ),
            ),
          ),
        ),
        // Display error message if present
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
