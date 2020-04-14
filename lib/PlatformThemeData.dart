import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/theme/T.dart';

class PlatformThemeData {
  final Color primaryColor;

  PlatformThemeData({this.primaryColor});

  material() {
    return ThemeData(primaryColor: primaryColor, brightness: Brightness.light);
  }

  cupertino() {
    SystemUiOverlayStyle(statusBarBrightness: Brightness.light);

    return CupertinoThemeData(
        primaryColor: primaryColor,
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(primaryColor: Colors.white, textStyle: TextStyle(color: T.COLOR_BLACK, fontSize: 16)));
  }
}
