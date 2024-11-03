import 'package:flutter/material.dart';

class AppTheme {
  AppTheme();
  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Color card1 = const Color(0xFFFFBF37);
  static Color card2 = const Color(0xFF00CECE);
  static Color card3 = const Color(0xFFFB777A);
  static Color card4 = const Color(0xFFA5A5A5);
  static Color card5 = const Color.fromARGB(255, 189, 154, 118);
  static Color card6 = const Color(0xFF333333);
  static Color card7 = const Color(0xFF6200EE);
    static Color card8 = const Color.fromARGB(255, 255, 255, 255);
}
