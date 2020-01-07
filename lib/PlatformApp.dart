import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformAwareWidget.dart';
import 'package:fyx/PlatformThemeData.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/pages/HomePage.dart';
import 'package:fyx/pages/TokenPage.dart';

class PlatformApp extends PlatformAwareWidget<MaterialApp, CupertinoApp> {
  final Widget home;
  final String title;
  final PlatformThemeData theme;

  PlatformApp({this.home, this.title, this.theme});

  @override
  MaterialApp createAndroidWidget(BuildContext context) {
    return MaterialApp(
      home: this.home,
      title: this.title,
      theme: this.theme?.material(),
      onGenerateRoute: routes,
    );
  }

  @override
  CupertinoApp createCupertinoWidget(BuildContext context) {
    return CupertinoApp(
      home: this.home,
      title: this.title,
      theme: this.theme?.cupertino(),
      onGenerateRoute: routes,
      onUnknownRoute: (RouteSettings settings) => CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings),
    );
  }

  Route routes(RouteSettings settings) {
    switch (settings.name) {
      case '/token':
        print('[Router] Token');
        return CupertinoPageRoute(builder: (_) => TokenPage(), settings: settings);
      case '/home':
        print('[Router] Homepage');
        return CupertinoPageRoute(builder: (_) => HomePage(), settings: settings);
      case '/discussion':
        print('[Router] Discussion');
        return CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings);
      default:
        print('[Router] Discussion');
        return CupertinoPageRoute(builder: (_) => DiscussionPage(), settings: settings);
    }
  }
}
