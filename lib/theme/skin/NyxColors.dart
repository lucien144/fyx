import 'dart:ui';

import 'package:flutter/material.dart';

class NyxColors {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color barBackgroundColor;
  Color? primaryContrastingColor;
  final Color scaffoldBackgroundColor;
  final Color textColor;
  final Color pollBackground;
  final Color pollAnswer;
  final Color pollAnswerSelected;
  final Color disabledColor;
  final BoxDecoration shadow;
  final LinearGradient gradient;

  NyxColors({
    this.accentColor = const Color(0xffB60F0F),
    this.primaryColor = const Color(0xFF196378),
    this.secondaryColor = const Color(0xff007F90),
    this.barBackgroundColor = const Color(0xfff0f4f5),
    this.scaffoldBackgroundColor = Colors.white,
    this.primaryContrastingColor,
    this.textColor = Colors.black,
    this.pollBackground = const Color(0xffcde5e9),
    this.pollAnswer = const Color(0xffa9ccd3),
    this.pollAnswerSelected = const Color(0xff76b9b9),
    this.disabledColor = Colors.black26,
  })  : shadow = BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: scaffoldBackgroundColor,
            border: Border.fromBorderSide(BorderSide(color: primaryColor, width: 1, style: BorderStyle.solid)),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16)]),
        gradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), primaryColor]);
}
