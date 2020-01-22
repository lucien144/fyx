import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/T.dart';

enum Environment { dev, staging, production }

class FyxApp extends StatelessWidget {
  final Credentials _credentials;

  static Environment _env;

  static set env(val) => FyxApp._env = val;

  static get env => FyxApp._env;
  static get isDev => FyxApp.env == Environment.dev;
  static get isStaging => FyxApp.env == Environment.staging;
  static get isProduction => FyxApp.env == Environment.production;

  const FyxApp(this._credentials, {Key key}) : super(key: key);

  setEnv(env) {
    FyxApp.env = env;
  }

  static init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide the keyboard on tap
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: PlatformApp(
        title: 'Fyx',
        theme: PlatformThemeData(primaryColor: T.COLOR_PRIMARY),
        home: _credentials is Credentials && _credentials.isValid ? HomePage() : LoginPage(),
      ),
    );
  }
}
