import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class FyxSkin extends SkinData {
  FyxSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory FyxSkin.create() {
    final lightColors = SkinColors();
    final darkColors = SkinColors(
      barBackgroundColor: const Color(0xff2d333b),
      textColor: const Color(0xFFadbac7),
      primaryColor: const Color(0xff316775),
      highlightColor: const Color(0xff00242e),
      primaryContrastingColor: const Color(0xFF1c2128),
      pollBackground: const Color(0xff2d333b),
      pollAnswer: const Color(0xff677578),
      pollAnswerSelected: const Color(0xff316775),
      scaffoldBackgroundColor: const Color(0xFF1C2128),
      disabledColor: const Color(0xFFadbac7),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff316775), Color(0xff00242e)])
    );

    return FyxSkin(
        lightData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: lightColors.barBackgroundColor,
                primaryColor: lightColors.primaryColor,
                scaffoldBackgroundColor: lightColors.scaffoldBackgroundColor,
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: lightColors.textColor, fontSize: 16))),
            colors: lightColors),
        darkData: SkinBrightnessData<SkinColors>(
            data: CupertinoThemeData(
                barBackgroundColor: darkColors.barBackgroundColor,
                primaryContrastingColor: darkColors.primaryContrastingColor,
                scaffoldBackgroundColor: darkColors.scaffoldBackgroundColor,
                primaryColor: darkColors.primaryColor,
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: darkColors.textColor, fontSize: 16))),
            colors: darkColors));
  }
}
