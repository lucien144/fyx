import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:google_fonts/google_fonts.dart';

class FyxSkin extends SkinData {
  final id = SkinEnum.fyx;
  final name = 'Fyx';

  FyxSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory FyxSkin.create({required double fontSize}) {
    final lightColors = SkinColors();
    final darkColors = SkinColors(
        primary: const Color(0xff4898ad),
        background: const Color(0xFF1C2128),
        barBackground: const Color(0xff2d333b),
        text: const Color(0xFFadbac7),
        grey: CupertinoColors.inactiveGray,
        danger: const Color(0xffe5534b),
        highlight: const Color(0xff33BB9A),
        disabled: const Color(0xFFadbac7),
        pollBackground: const Color(0xff2d333b),
        pollAnswer: const Color(0xff677578),
        pollAnswerSelected: const Color(0xff316775),
        primaryContrasting: const Color(0xff4898ad),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff316775), Color(0xff00242e)]));

    return FyxSkin(
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
