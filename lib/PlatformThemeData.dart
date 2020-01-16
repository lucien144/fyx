import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/T.dart';

class PlatformThemeData {
  final Color primaryColor;

  PlatformThemeData({this.primaryColor});

  material() {
    return ThemeData(primaryColor: primaryColor);
  }

  cupertino() {
    return CupertinoThemeData(primaryColor: primaryColor, textTheme: CupertinoTextThemeData(textStyle: TextStyle(color: T.COLOR_BLACK, fontSize: 16)));
  }
}
