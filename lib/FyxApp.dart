import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/libs/DeviceInfo.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/GalleryPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/pages/NoticesPage.dart';
import 'package:fyx/pages/SettingsPage.dart';
import 'package:fyx/pages/TutorialPage.dart';
import 'package:fyx/theme/T.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'controllers/NotificationsService.dart';

enum Environment { dev, staging, production }

class FyxApp extends StatefulWidget {
  static late Environment _env;

  static set env(val) => FyxApp._env = val;

  static get env => FyxApp._env;

  static get isDev => FyxApp.env == Environment.dev;

  static get isStaging => FyxApp.env == Environment.staging;

  static get isProduction => FyxApp.env == Environment.production;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static late RouteObserver<PageRoute> _routeObserver;

  static late NotificationService _notificationsService;

  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  setEnv(env) {
    FyxApp.env = env;
  }

  static get routeObserver {
    if (_routeObserver == null) {
      _routeObserver = RouteObserver<PageRoute>();
    }
    return _routeObserver;
  }

  static init() async {
    // This must be initialized after WidgetsFlutterBinding.ensureInitialized
    FlutterError.onError = (details, {bool forceReport = false}) {
      try {
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
      } finally {
        // Also use Flutter's pretty error logging to the device's console.
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
      }
    };

    if (FyxApp.isDev) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        String stack = '${DateTime.now()}: ${details.exceptionAsString()}';
        return T.somethingsWrongButton(stack);
      };
    }

    SystemUiOverlayStyle(statusBarBrightness: Brightness.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // TODO: Move to build using FutureBuilder.
    var results = await Future.wait([ApiController().getCredentials(), PackageInfo.fromPlatform(), DeviceInfo.init(), SettingsProvider().init()]);
    MainRepository().credentials = results[0] as Credentials;
    MainRepository().packageInfo = results[1] as PackageInfo;
    MainRepository().deviceInfo = results[2] as DeviceInfo;
    MainRepository().settings = results[3] as SettingsProvider;

    _notificationsService = NotificationService(
      onToken: (fcmToken) => ApiController().registerFcmToken(fcmToken),
      // TODO: Do not register if the token is already saved.
      onTokenRefresh: (fcmToken) => ApiController().refreshFcmToken(fcmToken),
    );
    _notificationsService.onNewMail = () =>
        FyxApp.navigatorKey.currentState!.pushReplacementNamed('/home',
            arguments: HomePageArguments(HomePage.PAGE_MAIL));
    _notificationsService.onNewPost = ({discussionId, postId}) {
      if (discussionId! > 0 && postId! > 0) {
        FyxApp.navigatorKey.currentState!.pushNamed('/discussion', arguments: DiscussionPageArguments(discussionId, postId: postId + 1));
      } else if (discussionId > 0) {
        FyxApp.navigatorKey.currentState!.pushNamed('/discussion', arguments: DiscussionPageArguments(discussionId));
      } else {
        FyxApp.navigatorKey.currentState!.pushReplacementNamed('/home', arguments: HomePageArguments(HomePage.PAGE_BOOKMARK));
      }
    };
    _notificationsService.onError = (error) {
      print(error);
      Sentry.captureException(error);
    };
    MainRepository().notifications = _notificationsService;

    AnalyticsProvider.provider = analytics;
  }

  @override
  _FyxAppState createState() => _FyxAppState();
}

class _FyxAppState extends State<FyxApp> {
  Route routes(RouteSettings settings) {
    switch (settings.name) {
      case '/token':
        print('[Router] Token');
        return CupertinoPageRoute(builder: (_) => TutorialPage(), settings: settings);
      case '/home':
        print('[Router] Homepage');
        return CupertinoPageRoute(builder: (_) => HomePage(), settings: settings);
      case '/login':
        print('[Router] Login');
        return CupertinoPageRoute(builder: (_) => LoginPage(), settings: settings);
      case '/discussion':
        print('[Router] Discussion');
        return CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings);
      case '/new-message':
        print('[Router] New Message');
        return CupertinoPageRoute(builder: (_) => NewMessagePage(), settings: settings, fullscreenDialog: true);
      case '/gallery':
        print('[Router] Gallery');
        return PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 0), opaque: false, pageBuilder: (_, __, ___) => GalleryPage(), settings: settings, fullscreenDialog: true);
      case '/settings':
        print('[Router] Settings');
        return CupertinoPageRoute(builder: (_) => SettingsPage(), settings: settings);
      case '/settings/info':
        print('[Router] Settings / info');
        return CupertinoPageRoute(builder: (_) => InfoPage(), settings: settings);
      case '/notices':
        print('[Router] Notices');
        return CupertinoPageRoute(builder: (_) => NoticesPage(), settings: settings);
      default:
        print('[Router] Discussion');
        return CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings);
    }
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
        ],
        child: CupertinoApp(
          title: 'Fyx',
          theme: CupertinoThemeData(
              primaryColor: T.COLOR_PRIMARY,
              brightness: Brightness.light,
              textTheme: CupertinoTextThemeData(primaryColor: Colors.white, textStyle: TextStyle(color: T.COLOR_BLACK, fontSize: 16))),
          home: MainRepository().credentials is Credentials && MainRepository().credentials.isValid ? HomePage() : LoginPage(),
          debugShowCheckedModeBanner: FyxApp.isDev,
          onUnknownRoute: (RouteSettings settings) => CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings),
          onGenerateRoute: routes,
          navigatorKey: FyxApp.navigatorKey,
          navigatorObservers: [
            FyxApp.routeObserver,
            FirebaseAnalyticsObserver(
                analytics: FyxApp.analytics,
                onError: (error) async => await Sentry.captureException(
                      error,
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
