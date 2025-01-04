import 'package:flutter/material.dart';

class ButtonAdd extends StatelessWidget {
  const ButtonAdd({
    super.key,
    this.label,
    this.icon,
    this.color,
    this.size,
    this.onTap,
  });

  final String? label;
  final Widget? icon;
  final Color? color;
  final Size? size;

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      child: ElevatedButton.icon(
        onPressed: () {
          // Action to perform when the button is pressed

          onTap;
        },
        icon: icon,
        label: Text(
          label!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.cyanAccent,
          foregroundColor: Colors.white,
          minimumSize: size,
        ),
      ),
    );
  }
}
