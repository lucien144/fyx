import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:toastification/toastification.dart';

class SkinnedApp extends StatelessWidget {
  const SkinnedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
          title: 'Fyx',
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (context, child) {
            final cupertinoData = Skin.of(context).theme.data;
            return DefaultTextStyle(
              style: cupertinoData.textTheme.textStyle,
              child: CupertinoTheme(
                data: cupertinoData,
                child: child!,
              ),
            );
          },
          home: MainRepository().credentials != null && MainRepository().credentials!.isValid ? HomePage() : LoginPage(),
          debugShowCheckedModeBanner: FyxApp.isDev,
          onUnknownRoute: (RouteSettings settings) => MaterialPageRoute(builder: (_) => DiscussionPage(), settings: settings),
          onGenerateRoute: FyxApp.routes,
          navigatorKey: FyxApp.navigatorKey,
          navigatorObservers: [
            FyxApp.routeObserver,
            FirebaseAnalyticsObserver(
                analytics: FyxApp.analytics,
                onError: (error) => LogService.captureError(
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
          ]),
    );
  }
}