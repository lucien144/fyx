import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/NyxColors.dart';
import 'package:fyx/theme/skin/Skin.dart';

class NyxSkin extends SkinData {
  NyxSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory NyxSkin.create() {
    final lightColors = NyxColors();
    final darkColors = NyxColors(
      barBackgroundColor: const Color(0xff2d333b),
      textColor: const Color(0xFFadbac7),
      primaryColor: const Color(0xff316775),
      primaryContrastingColor: const Color(0xFF1c2128),
      pollBackground: const Color(0xff2d333b),
      pollAnswer: const Color(0xff677578),
      pollAnswerSelected: const Color(0xff316775),
      scaffoldBackgroundColor: const Color(0xFF1C2128),
      disabledColor: const Color(0xFFadbac7),
    );

    return NyxSkin(
        lightData: SkinBrightnessData<NyxColors>(
            data: CupertinoThemeData(
                barBackgroundColor: lightColors.barBackgroundColor,
                primaryColor: lightColors.primaryColor,
                scaffoldBackgroundColor: lightColors.scaffoldBackgroundColor,
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: lightColors.textColor, fontSize: 16))),
            colors: lightColors),
        darkData: SkinBrightnessData<NyxColors>(
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
