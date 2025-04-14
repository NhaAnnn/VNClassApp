import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BackBar extends StatelessWidget {
  const BackBar({
    super.key,
    this.title,
    this.shape,
    this.backgroundColor,
    this.leading = true,
  });

  final ShapeBorder? shape;
  final Color? backgroundColor;
  final String? title;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.blue,
      centerTitle: true,
      title: Text(title!),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
      leading: leading
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
                ),
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.blueAccent,
                  size: 16,
                ), // Custom back button icon
                onPressed: () {
                  Navigator.pop(context); // Navigate back
                },
              ),
            )
          : null,
      titleSpacing: 0.5,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }
}
