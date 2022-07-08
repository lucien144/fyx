import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/SkinnedApp.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/libs/DeviceInfo.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:fyx/model/provider/NotificationsModel.dart';
import 'package:fyx/model/provider/ThemeModel.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/GalleryPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/pages/LoginPage.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/pages/NoticesPage.dart';
import 'package:fyx/pages/TutorialPage.dart';
import 'package:fyx/pages/discussion_home_page.dart';
import 'package:fyx/pages/settings_design_screen.dart';
import 'package:fyx/pages/settings_screen.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/skins/FyxSkin.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:tap_canvas/tap_canvas.dart';

import 'controllers/NotificationsService.dart';

enum Environment { dev, staging, production }

class FyxApp extends StatefulWidget {
  static Environment _env = Environment.dev;

  static set env(val) => FyxApp._env = val;

  static get env => FyxApp._env;

  static get isDev => FyxApp.env == Environment.dev;

  static get isStaging => FyxApp.env == Environment.staging;

  static get isProduction => FyxApp.env == Environment.production;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  static late NotificationService _notificationsService;

  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  setEnv(env) {
    FyxApp.env = env;
  }

  static get routeObserver {
    return _routeObserver;
  }

  static init() async {
    await Firebase.initializeApp();

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

    if (FyxApp.isProduction) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        String stack = '${DateTime.now()}: ${details.exceptionAsString()}';
        return T.somethingsWrongButton(stack);
      };
    }

    SystemUiOverlayStyle(statusBarBrightness: Brightness.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    // TODO: Move to build using FutureBuilder.
    var results = await Future.wait([ApiController().getCredentials(), PackageInfo.fromPlatform(), DeviceInfo.init(), SettingsProvider().init()]);
    MainRepository().credentials = results[0] == null ? null : results[0] as Credentials;
    MainRepository().packageInfo = results[1] as PackageInfo;
    MainRepository().deviceInfo = results[2] as DeviceInfo;
    MainRepository().settings = results[3] as SettingsProvider;

    _notificationsService = NotificationService(
      onToken: (fcmToken) => ApiController().registerFcmToken(fcmToken),
      // TODO: Do not register if the token is already saved.
      onTokenRefresh: (fcmToken) => ApiController().refreshFcmToken(fcmToken),
    );
    _notificationsService.configure();
    _notificationsService.onNewMail =
        () => FyxApp.navigatorKey.currentState!.pushReplacementNamed('/home', arguments: HomePageArguments(HomePage.PAGE_MAIL));
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

  static Route routes(RouteSettings settings) {
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
      case '/discussion/home':
        print('[Router] Discussion home');
        return CupertinoPageRoute(builder: (_) => DiscussionHomePage(), settings: settings);
      case '/discussion/header':
        print('[Router] Discussion home');
        return CupertinoPageRoute(builder: (_) => DiscussionHomePage(header: true), settings: settings);
      case '/new-message':
        print('[Router] New Message');
        return CupertinoPageRoute(builder: (_) => NewMessagePage(), settings: settings, fullscreenDialog: true);
      case '/gallery':
        print('[Router] Gallery');
        return PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 0),
            opaque: false,
            pageBuilder: (_, __, ___) => GalleryPage(),
            settings: settings,
            fullscreenDialog: true);
      case '/settings':
        print('[Router] Settings');
        return CupertinoPageRoute(builder: (_) => SettingsScreen(), settings: settings);
      case '/settings/design':
        print('[Router] Settings');
        return CupertinoPageRoute(builder: (_) => SettingsDesignScreen(), settings: settings);
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
  _FyxAppState createState() => _FyxAppState();
}

class _FyxAppState extends State<FyxApp> with WidgetsBindingObserver {
  Brightness? _platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _platformBrightness ??= WidgetsBinding.instance?.window.platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return TapCanvas(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationsModel>(create: (context) => NotificationsModel()),
          ChangeNotifierProvider<ThemeModel>(create: (context) => ThemeModel(MainRepository().settings.theme, MainRepository().settings.fontSize)),
        ],
        builder: (ctx, widget) => Directionality(
            textDirection: TextDirection.ltr,
            child: Skin(
                skin: FyxSkin.create(fontSize: ctx.watch<ThemeModel>().fontSize),
                brightness: (() {
                  if (ctx.watch<ThemeModel>().theme == ThemeEnum.system && _platformBrightness != null) {
                    return _platformBrightness!;
                  }
                  return ctx.watch<ThemeModel>().theme == ThemeEnum.light ? Brightness.light : Brightness.dark;
                })(),
                child: SkinnedApp())),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    FyxApp._notificationsService.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    setState(() => _platformBrightness = WidgetsBinding.instance?.window.platformBrightness);
    super.didChangePlatformBrightness(); // make sure you call this
  }
}
