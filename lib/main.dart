import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/PlatformApp.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(FyxApp());
}

class FyxApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Fyx',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Fyx'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.loop),
                title: Text('Historie'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                title: Text('Sledovane'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.mail),
                title: Text('Posta'),
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: Container(),
                  );
                });
              case 1:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: Container(),
                  );
                });
              case 2:
                return CupertinoTabView(builder: (context) {
                  return CupertinoPageScaffold(
                    child: Container(),
                  );
                });
              default:
                throw Exception('Selected undefined tab');
            }
          },
        ),
      )
    );
  }
}
