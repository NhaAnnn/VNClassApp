import 'package:flutter/material.dart';

class ButtonN extends StatelessWidget {
  const ButtonN({
    super.key,
    this.label,
    this.icon,
    this.color,
    this.size,
    this.textSize,
    this.borderRadius,
    this.colorText,
    this.ontap,
  });

  final String? label;
  final Widget? icon;
  final Color? color; // Color property for the button
  final Size? size;
  final double? textSize;
  final Color? colorText;
  final BorderRadius? borderRadius;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: size?.height ?? 48, // Default height
        width: size?.width, // Allow width to be flexible
        constraints: BoxConstraints(
          maxWidth: double.infinity, // Allow the button to take full width
        ),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          color: color ?? Colors.cyan.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                bottom: MediaQuery.of(context).size.width * 0.02),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon ??
                    SizedBox(width: 0), // Show icon or SizedBox with width 0
                if (icon != null) SizedBox(width: 10), // Conditional spacing
                Text(
                  label ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorText ?? Colors.black,
                    fontSize: textSize ?? 16, // Default text size
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
