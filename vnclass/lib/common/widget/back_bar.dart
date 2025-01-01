import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BackBar extends StatelessWidget {
  const BackBar({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(title!),
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.arrowLeft), // Custom back button icon
        onPressed: () {
          Navigator.pop(context); // Navigate back
        },
      ),
      titleSpacing: 0.5,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }
}