import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformAwareWidget.dart';
import 'package:fyx/PlatformThemeData.dart';

class PlatformApp extends PlatformAwareWidget<MaterialApp, CupertinoApp> {

  final Widget home;
  final String title;
  final PlatformThemeData theme;

  PlatformApp({this.home, this.title, this.theme});

  @override
  MaterialApp createAndroidWidget(BuildContext context) {
    return MaterialApp(home: this.home,title: this.title, theme: this.theme?.material());
  }

  @override
  CupertinoApp createCupertinoWidget(BuildContext context) {
    return CupertinoApp(home: this.home, title: this.title, theme: this.theme?.cupertino());
  }
}