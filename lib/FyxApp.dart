import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/provider/SettingsModel.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/T.dart';
import 'package:provider/provider.dart';

enum Environment { dev, staging, production }

class FyxApp extends StatelessWidget {
  static Environment _env;

  static set env(val) => FyxApp._env = val;

  static get env => FyxApp._env;

  static get isDev => FyxApp.env == Environment.dev;

  static get isStaging => FyxApp.env == Environment.staging;

  static get isProduction => FyxApp.env == Environment.production;

  static RouteObserver<PageRoute> _routeObserver;
  static get routeObserver {
    if (_routeObserver == null) {
      _routeObserver = RouteObserver<PageRoute>();
    }
    return _routeObserver;
  }

  setEnv(env) {
    FyxApp.env = env;
  }

  static init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    MainRepository().credentials = await ApiController().provider.getCredentials();
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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationsModel>(create: (context) => NotificationsModel()),
          ChangeNotifierProvider<SettingsModel>(create: (context) => SettingsModel())
        ],
        child: PlatformApp(
          title: 'Fyx',
          theme: PlatformThemeData(primaryColor: T.COLOR_PRIMARY),
          home: MainRepository().credentials is Credentials && MainRepository().credentials.isValid ? HomePage() : LoginPage(),
          debugShowCheckedModeBanner: FyxApp.isDev,
          listNavigatorObservers: [FyxApp.routeObserver],
        ),
      ),
    );
  }
}
