import 'package:flutter/material.dart';

class ButtonN extends StatelessWidget {
  const ButtonN({
    super.key,
    this.label,
    this.icon,
    this.color,
    this.size,
    this.textSize,
    this.colorText,
    this.ontap,
  });

  final String? label;
  final Widget? icon;
  final Color? color; // Color property for the button
  final Size? size;
  final double? textSize;
  final Color? colorText;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: size?.height,
        width: size?.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: color ?? Colors.amber,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon ?? SizedBox(width: 0), // Show icon or SizedBox with width 0
              icon != null
                  ? SizedBox(width: 10)
                  : SizedBox(width: 0), // Conditional sizing
              Text(
                label ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorText ?? Colors.amber,
                  fontSize: textSize, // Change text color if needed
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
