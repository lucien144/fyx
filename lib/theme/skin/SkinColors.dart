import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SkinColors {
  final Color primary;

  //final Color secondaryColor;
  final Color highlight;
  final Color highlightedText;
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
  final Color twitter;
  final Color divider;
  final BoxDecoration shadow;
  final LinearGradient gradient;
  final BoxDecoration textFieldDecoration;
  Color? primaryContrasting;

  SkinColors({
    this.primary = const Color(0xFF196378),
    this.background = Colors.white,
    this.barBackground = const Color(0xfff0f4f5),
    this.text = const Color(0xFF282828),
    this.success = Colors.green,
    this.danger = Colors.redAccent,
    this.highlight = const Color(0xff33BB9A),
    this.highlightedText = Colors.amber,
    this.light = Colors.white,
    this.dark = const Color(0xFF282828),
    this.grey = Colors.black38,
    this.disabled = Colors.black26,
    this.pollBackground = const Color(0xffcde5e9),
    this.pollAnswer = const Color(0xffa9ccd3),
    this.pollAnswerSelected = const Color(0xff76b9b9),
    this.twitter = const Color(0xff1DA1F2),
    this.divider = const Color(0xffe0e0e0),
    this.gradient = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xFF196378)]),
    this.textFieldDecoration = const BoxDecoration(
      color: CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.white,
        darkColor: CupertinoColors.black,
      ),
      border: Border.fromBorderSide(BorderSide(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0x33000000),
          darkColor: Color(0x33FFFFFF),
        ),
        width: 0.0,
      )),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    this.primaryContrasting,
    //this.secondaryColor = const Color(0xff007F90),
  }) : shadow = BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: background,
            border: Border.fromBorderSide(BorderSide(color: primary, width: 1, style: BorderStyle.solid)),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16)]);
}
