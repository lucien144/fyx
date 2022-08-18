import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:google_fonts/google_fonts.dart';

class ForestSkin extends SkinData {
  final id = SkinEnum.forest;
  final name = 'Forest4';

  ForestSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory ForestSkin.create({required double fontSize}) {
    final lightColors = SkinColors(
      primary: const Color(0xFF3B4F41),
      primaryContrasting: const Color(0xffcccdb1),
      background: const Color(0xffb8b992), // #B8B992
      barBackground: const Color(0xff87937b), // #617E69
      text: const Color(0xFF282828),
      success: Color(0xff617e6a),
      danger: const Color(0xffb60f0f),
      highlight: const Color(0xffDBD68B),
      highlightedText: Colors.amber,
      light: Colors.white,
      dark: const Color(0xFF282828),
      grey: Color(0xFF3B4F41).withOpacity(.7),
      disabled: Colors.black26,
      pollBackground: const Color(0xffcde5e9),
      pollAnswer: const Color(0xffa9ccd3),
      pollAnswerSelected: const Color(0xff76b9b9),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xFF196378)]),
    );
    final darkColors = lightColors;

    return ForestSkin(
        lightData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: lightColors.barBackground,
                primaryColor: lightColors.primary,
                scaffoldBackgroundColor: lightColors.background,
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(textStyle: GoogleFonts.inter(color: lightColors.text, fontSize: fontSize))),
            colors: lightColors),
        darkData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: darkColors.barBackground,
                primaryContrastingColor: darkColors.primaryContrasting,
                scaffoldBackgroundColor: darkColors.background,
                primaryColor: darkColors.primary,
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(textStyle: GoogleFonts.inter(color: darkColors.text, fontSize: fontSize))),
            colors: darkColors));
  }
}
