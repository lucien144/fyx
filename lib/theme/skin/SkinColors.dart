import 'dart:ui';

import 'package:flutter/material.dart';

class SkinColors {
  final Color primary;
  //final Color secondaryColor;
  final Color highlight;
  final Color success;
  final Color danger;
  final Color barBackground;
  final Color background;
  final Color text;
  final Color pollBackground;
  final Color pollAnswer;
  final Color pollAnswerSelected;
  final Color disabled;
  final Color grey;
  final Color light;
  final Color dark;
  final BoxDecoration shadow;
  final LinearGradient gradient;
  Color? primaryContrasting;

  SkinColors({
    this.danger = Colors.redAccent,
    this.success = Colors.green,
    this.primary = const Color(0xFF196378),
    //this.secondaryColor = const Color(0xff007F90),
    this.highlight = const Color(0xff1AD592),
    this.barBackground = const Color(0xfff0f4f5),
    this.background = Colors.white,
    this.primaryContrasting,
    this.text = const Color(0xFF282828),
    this.pollBackground = const Color(0xffcde5e9),
    this.pollAnswer = const Color(0xffa9ccd3),
    this.pollAnswerSelected = const Color(0xff76b9b9),
    this.disabled = Colors.black26,
    this.grey = Colors.black38,
    this.light = Colors.white,
    this.dark = const Color(0xFF282828),
    this.gradient = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xFF196378)]),
  })  : shadow = BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: background,
            border: Border.fromBorderSide(BorderSide(color: primary, width: 1, style: BorderStyle.solid)),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16)]);
}
