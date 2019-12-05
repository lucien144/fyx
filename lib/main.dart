import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(FyxApp(await ApiController.getCredentials()));
}

class FyxApp extends StatelessWidget {
  final Credentials _credentials;

  const FyxApp(this._credentials, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Fyx',
      theme: PlatformThemeData(primaryColor: Color(0xFF009D9D)), // Color schema -> https://mycolor.space/?hex=%231AD592&sub=1
      home: _credentials is Credentials && _credentials.isValid ? HomePage() : LoginPage(),
    );
  }
}
