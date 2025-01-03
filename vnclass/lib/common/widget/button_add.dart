import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ButtonAdd extends StatelessWidget {
  const ButtonAdd({
    super.key,
    this.label,
    this.icon,
    this.color,
    this.size,
  });

  final String? label;
  final Widget? icon;
  final Color? color;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      child: ElevatedButton.icon(
        onPressed: () {
          // Action to perform when the button is pressed
          print('Alooo');
        },
        // icon: Icon(
        //   FontAwesomeIcons.addressCard,
        //   color: Colors.white,
        // ),
        icon: icon,
        label: Text(
          label!, // Replace with your desired text
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.cyanAccent,
          foregroundColor: Colors.white,
          minimumSize: size, // Set the minimum width and height
        ),
      ),
    );
  }
}
