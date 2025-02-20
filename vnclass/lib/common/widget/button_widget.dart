import 'package:flutter/material.dart';
import 'package:vnclass/common/design/color.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.title,
    this.ontap,
    this.color,
  });

  final String title;
  final Function()? ontap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //timf hieeur
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color ?? ColorApp.primaryColor,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
