import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/pages/HomePage.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(FyxApp());
}

class FyxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Fyx',
      theme: PlatformThemeData(primaryColor: Color(0xFF009D9D)), // Color schema -> https://mycolor.space/?hex=%231AD592&sub=1
      home: HomePage(),
    );
  }
}
