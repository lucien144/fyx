import 'dart:ui';

import 'package:flutter/material.dart';

class NyxColors {
  final Color primaryColor;
  final Color accentColor;
  final Color barBackgroundColor;
  Color? primaryContrastingColor;
  final Color scaffoldBackgroundColor;
  final Color textColor;
  final Color pollBackground;
  final Color pollAnswer;
  final Color pollAnswerSelected;
  final Color disabledColor;

  NyxColors({
    this.accentColor = const Color(0xffB60F0F),
    this.primaryColor = const Color(0xFF196378),
    this.barBackgroundColor = const Color(0xfff0f4f5),
    this.scaffoldBackgroundColor = Colors.white,
    this.primaryContrastingColor,
    this.textColor = Colors.black,
    this.pollBackground = const Color(0xffcde5e9),
    this.pollAnswer = const Color(0xffa9ccd3),
    this.pollAnswerSelected = const Color(0xff76b9b9),
    this.disabledColor = Colors.black26,
  });
}
