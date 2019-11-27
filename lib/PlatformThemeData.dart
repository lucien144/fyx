import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformThemeData {
  final Color primaryColor;

  PlatformThemeData({this.primaryColor});

  material() {
    return ThemeData(primaryColor: primaryColor);
  }

  cupertino() {
    return CupertinoThemeData(primaryColor: primaryColor);
  }
}
