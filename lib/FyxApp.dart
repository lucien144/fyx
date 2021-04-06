import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/theme/T.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';

import 'PlatformTheme.dart';
import 'controllers/NotificationsService.dart';

enum Environment { dev, staging, production }

class FyxApp extends StatefulWidget {
  static Environment _env;

  static set env(val) => FyxApp._env = val;

  static get env => FyxApp._env;

  static get isDev => FyxApp.env == Environment.dev;

  static get isStaging => FyxApp.env == Environment.staging;

  static get isProduction => FyxApp.env == Environment.production;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static RouteObserver<PageRoute> _routeObserver;

  static NotificationService _notificationsService;

  setEnv(env) {
    FyxApp.env = env;
  }

  static get routeObserver {
    if (_routeObserver == null) {
      _routeObserver = RouteObserver<PageRoute>();
    }
    return _routeObserver;
  }

  static init(SentryClient sentry) async {
    // This must be initialized after WidgetsFlutterBinding.ensureInitialized
    FlutterError.onError = (details, {bool forceReport = false}) {
      try {
        sentry.captureException(
          exception: details.exception,
          stackTrace: details.stack,
        );
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
      } finally {
        // Also use Flutter's pretty error logging to the device's console.
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
      }
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      String stack = '${DateTime.now()}: ${details.exceptionAsString()}';
      return PlatformTheme.somethingsWrongButton(stack);
    };

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // TODO: Move to build using FutureBuilder.
    var results = await Future.wait([
      ApiController().getCredentials(),
      PackageInfo.fromPlatform(),
      DeviceInfoPlugin().iosInfo,
      SettingsProvider().init()
    ]);
    MainRepository().credentials = results[0];
    MainRepository().packageInfo = results[1];
    MainRepository().deviceInfo = results[2];
    MainRepository().settings = results[3];
    MainRepository().sentry = sentry;

    _notificationsService = NotificationService(
      onToken: (fcmToken) => ApiController().registerFcmToken(fcmToken),
      // TODO: Do not register if the token is already saved.
      onTokenRefresh: (fcmToken) => ApiController().refreshFcmToken(fcmToken),
    );
    _notificationsService.onNewMail = () =>
        PlatformApp.navigatorKey.currentState.pushReplacementNamed('/home',
            arguments: HomePageArguments(HomePage.PAGE_MAIL));
    _notificationsService.onNewPost = ({discussionId, postId}) {
      if (discussionId > 0 && postId > 0) {
        PlatformApp.navigatorKey.currentState.pushNamed('/discussion', arguments: DiscussionPageArguments(discussionId, postId: postId));
      } else if (discussionId > 0) {
        PlatformApp.navigatorKey.currentState.pushNamed('/discussion', arguments: DiscussionPageArguments(discussionId));
      } else {
        PlatformApp.navigatorKey.currentState.pushReplacementNamed('/home', arguments: HomePageArguments(HomePage.PAGE_BOOKMARK));
      }
    };
    _notificationsService.onError = (error) {
      print(error);
      MainRepository().sentry.captureException(exception: error);
    };
    MainRepository().notifications = _notificationsService;

    AnalyticsProvider.provider = analytics;
  }

  @override
  _FyxAppState createState() => _FyxAppState();
}

class _FyxAppState extends State<FyxApp> {
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
          ChangeNotifierProvider<NotificationsModel>(
              create: (context) => NotificationsModel()),
        ],
        child: PlatformApp(
          title: 'Fyx',
          theme: PlatformThemeData(primaryColor: T.COLOR_PRIMARY),
          home: MainRepository().credentials is Credentials &&
                  MainRepository().credentials.isValid
              ? HomePage()
              : LoginPage(),
          debugShowCheckedModeBanner: FyxApp.isDev,
          listNavigatorObservers: [
            FyxApp.routeObserver,
            FirebaseAnalyticsObserver(
                analytics: FyxApp.analytics,
                onError: (error) async =>
                    await MainRepository().sentry.captureException(
                          exception: error,
                        ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    FyxApp._notificationsService.dispose();
  }
}
