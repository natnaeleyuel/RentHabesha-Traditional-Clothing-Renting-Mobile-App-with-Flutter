import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color brand = Color(0xFF19B579);
  static const Color strokeStrong = Color(0xFF288964);
  static const Color strokeWeak = Color(0xFF19B579);
  static const Color background = Color(0xFFF6F7FA);
  static const Color textStrong = Color(0xFF000000);
  static const Color textWeak = Color(0xFF8086A6);
  static const Color amberStatus = Color(0xFFFFA000);
  static const Color greenStatus = Color(0xFF4CAF50);

  // Dynamic colors based on theme
  static Color focusedTextFieldText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : textStrong;

  static Color unfocusedTextFieldText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey
          : textWeak;

  static Color focusedTextFieldStroke(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : strokeStrong;

  static Color unfocusedTextFieldStroke(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey
          : strokeWeak;

  static Color bodyText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : textStrong;
}