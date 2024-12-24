import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkSkin extends SkinData {
  final id = SkinEnum.dark;
  final name = 'Dark';
  final darkMode = false;

  DarkSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory DarkSkin.create({required double fontSize}) {
    final lightColors = SkinColors(
      primary: const Color(0xFFD0EB6A),
      primaryContrasting: const Color(0xffcccdb1),
      background: const Color(0xff0d0d0d), // #B8B992
      barBackground: const Color(0xff232526), // #617E69
      text: const Color(0xFFCCCCCC),
      success: Color(0xffD0EB6A),
      danger: const Color(0xffb60f0f),
      highlight: const Color(0xffDBD68B),
      divider: const Color(0xff151515),
      highlightedText: Colors.amber,
      light: Colors.white,
      dark: const Color(0xFF282828),
      grey: Color(0xFFD0EB6A).withOpacity(.25),
      disabled: Colors.white24,
      twitter: const Color(0xFF3B4F41),
      pollBackground: const Color(0xff3b3b3b),
      pollAnswer: const Color(0xff3b3b3b),
      pollAnswerSelected: const Color(0xff151515),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xFF196378)]),
      textFieldDecoration: const BoxDecoration(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0xff151515),
          darkColor: Color(0xff151515),
        ),
        border: Border.fromBorderSide(BorderSide(
          color: CupertinoDynamicColor.withBrightness(
            color: Color(0xff858585),
            darkColor: Color(0xff858585e),
          ),
          width: 0.0,
        )),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      )
    );
    final darkColors = lightColors;

    return DarkSkin(
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
