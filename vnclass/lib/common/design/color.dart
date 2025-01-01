import 'package:flutter/material.dart';

class ColorApp {
  static const Color primaryColor = Color(0xff38B6FF);
  static const Color secondColor = Color(0xff8BEBF1);
}

class Gradients {
  static const Gradient defaultGradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomLeft,
    colors: [
      ColorApp.secondColor,
      ColorApp.primaryColor,
    ],
  );
}
