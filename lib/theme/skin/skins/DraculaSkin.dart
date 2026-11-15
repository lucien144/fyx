import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Skin based on the well-known Dracula theme and its official light
/// counterpart, Alucard.
///
/// Light mode uses the Alucard palette, dark mode uses the Dracula palette.
/// See https://draculatheme.com and https://spec.draculatheme.com for the
/// canonical colors.
class DraculaSkin extends SkinData {
  final id = SkinEnum.dracula;
  final name = 'Dracula';
  final darkMode = true;

  DraculaSkin({lightData, darkData}) : super(lightData: lightData, darkData: darkData);

  factory DraculaSkin.create({required double fontSize}) {
    // Alucard (light) palette.
    final lightColors = SkinColors(
      primary: const Color(0xff644ac9), // purple
      primaryContrasting: const Color(0xff644ac9),
      background: const Color(0xfffffbeb),
      barBackground: const Color(0xfff4eeda),
      text: const Color(0xff1f1f1f),
      success: const Color(0xff14710a), // green
      danger: const Color(0xffcb3a2a), // red
      highlight: const Color(0xffa3144d), // pink
      highlightedText: const Color(0xff846e15), // yellow
      divider: const Color(0xffe8e2cd),
      light: CupertinoColors.white,
      dark: const Color(0xff1f1f1f),
      grey: const Color(0xff635d97), // comment
      disabled: const Color(0x33635d97),
      twitter: const Color(0xff036a96), // cyan
      pollBackground: const Color(0xffefe9d4),
      pollAnswer: const Color(0xffe0dabf),
      pollAnswerSelected: const Color(0xffcfcfde),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff644ac9), Color(0xffa3144d)]),
      textFieldDecoration: const BoxDecoration(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0xfffffbeb),
          darkColor: Color(0xfffffbeb),
        ),
        border: Border.fromBorderSide(BorderSide(
          color: CupertinoDynamicColor.withBrightness(
            color: Color(0xffcfcfde),
            darkColor: Color(0xffcfcfde),
          ),
          width: 0.0,
        )),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
    );

    // Dracula (dark) palette.
    final darkColors = SkinColors(
      primary: const Color(0xffbd93f9), // purple
      primaryContrasting: const Color(0xffbd93f9),
      background: const Color(0xff282a36),
      barBackground: const Color(0xff21222c),
      text: const Color(0xfff8f8f2),
      success: const Color(0xff50fa7b), // green
      danger: const Color(0xffff5555), // red
      highlight: const Color(0xffff79c6), // pink
      highlightedText: const Color(0xfff1fa8c), // yellow
      divider: const Color(0xff191a21),
      light: CupertinoColors.white,
      dark: const Color(0xff21222c),
      grey: const Color(0xff6272a4), // comment
      disabled: const Color(0xff6272a4),
      twitter: const Color(0xff8be9fd), // cyan
      pollBackground: const Color(0xff44475a),
      pollAnswer: const Color(0xff44475a),
      pollAnswerSelected: const Color(0xff6272a4),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xffbd93f9), Color(0xffff79c6)]),
      textFieldDecoration: const BoxDecoration(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0xff21222c),
          darkColor: Color(0xff21222c),
        ),
        border: Border.fromBorderSide(BorderSide(
          color: CupertinoDynamicColor.withBrightness(
            color: Color(0xff44475a),
            darkColor: Color(0xff44475a),
          ),
          width: 0.0,
        )),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
    );

    return DraculaSkin(
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
