import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformAwareWidget.dart';

class PlatformApp extends PlatformAwareWidget<MaterialApp, CupertinoApp> {

  final Widget home;
  final String title;

  PlatformApp({this.home, this.title});

  @override
  MaterialApp createAndroidWidget(BuildContext context) {
    return MaterialApp(home: this.home,title: this.title,);
  }

  @override
  CupertinoApp createCupertinoWidget(BuildContext context) {
    return CupertinoApp(home: this.home, title: this.title,theme: CupertinoThemeData(primaryColor: Colors.red),);
  }




}
