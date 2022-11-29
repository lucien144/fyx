import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:google_fonts/google_fonts.dart';

class ForestSkin extends SkinData {
  final id = SkinEnum.forest;
  final name = 'Forest4';
  final darkMode = false;

  ForestSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory ForestSkin.create({required double fontSize}) {
    final lightColors = SkinColors(
      primary: const Color(0xFF3B4F41),
      primaryContrasting: const Color(0xffcccdb1),
      background: const Color(0xffb8b992), // #B8B992
      barBackground: const Color(0xff87937b), // #617E69
      text: const Color(0xFF282828),
      success: Color(0xff4D6654),
      danger: const Color(0xffb60f0f),
      highlight: const Color(0xffDBD68B),
      highlightedText: Colors.amber,
      light: Colors.white,
      dark: const Color(0xFF282828),
      grey: Color(0xFF3B4F41).withOpacity(.7),
      disabled: Colors.black26,
      twitter: const Color(0xFF3B4F41),
      pollBackground: const Color(0xffcccdb1),
      pollAnswer: const Color(0xffb8b992),
      pollAnswerSelected: const Color(0xffDBD68B),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xFF196378)]),
      textFieldDecoration: const BoxDecoration(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0xffCCCCB1),
          darkColor: Color(0xffCCCCB1),
        ),
        border: Border.fromBorderSide(BorderSide(
          color: CupertinoDynamicColor.withBrightness(
            color: Color(0xff858B62),
            darkColor: Color(0xff858B62),
          ),
          width: 0.0,
        )),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      )
    );
    final darkColors = lightColors;

    return ForestSkin(
        lightData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: lightColors.barBackground,
                primaryColor: lightColors.primary,
                scaffoldBackgroundColor: lightColors.background,
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(textStyle: Platform.isIOS ? GoogleFonts.inter(color: lightColors.text, fontSize: fontSize) : TextStyle(color: lightColors.text, fontSize: fontSize))),
            colors: lightColors),
        darkData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: darkColors.barBackground,
                primaryContrastingColor: darkColors.primaryContrasting,
                scaffoldBackgroundColor: darkColors.background,
                primaryColor: darkColors.primary,
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(textStyle: Platform.isIOS ? GoogleFonts.inter(color: darkColors.text, fontSize: fontSize) : TextStyle(color: darkColors.text, fontSize: fontSize))),
            colors: darkColors));
  }
}
