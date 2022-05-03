import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SkinnedApp extends StatelessWidget {
  const SkinnedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Fyx',
        theme: Skin.of(context).theme.data,
        home: MainRepository().credentials != null && MainRepository().credentials!.isValid ? HomePage() : LoginPage(),
        debugShowCheckedModeBanner: FyxApp.isDev,
        onUnknownRoute: (RouteSettings settings) => CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings),
        onGenerateRoute: FyxApp.routes,
        navigatorKey: FyxApp.navigatorKey,
        navigatorObservers: [
          FyxApp.routeObserver,
          FirebaseAnalyticsObserver(
              analytics: FyxApp.analytics,
              onError: (error) async => await Sentry.captureException(
                    error,
                  ))
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('cs', ''),
          Locale('sk', ''),
        ]);
  }
}
