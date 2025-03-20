import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BackBar extends StatelessWidget {
  const BackBar({
    super.key,
    this.title,
    this.shape,
    this.backgroundColor,
  });

  final ShapeBorder? shape;
  final Color? backgroundColor;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.blue,
      title: Text(title!),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
      leading: IconButton(
        icon: Transform.rotate(
            angle: -1.57,
            child: Icon(
              FontAwesomeIcons.turnUp,
              color: Colors.white,
            )), // Custom back button icon
        onPressed: () {
          Navigator.pop(context); // Navigate back
        },
      ),
      titleSpacing: 0.5,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }
}
