import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CSWidgetStyle postsStyle = const CSWidgetStyle(icon: const Icon(Icons.view_compact, color: Colors.black54));
    CSWidgetStyle bugreportStyle = const CSWidgetStyle(icon: const Icon(Icons.bug_report, color: Colors.black54));
    CSWidgetStyle aboutStyle = const CSWidgetStyle(icon: const Icon(Icons.info, color: Colors.black54));
    CSWidgetStyle patronsStyle = const CSWidgetStyle(icon: const Icon(Icons.stars, color: Colors.black54));

    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';

    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.white,
              middle: Text(L.SETTINGS),
              leading: CupertinoNavigationBarBackButton(
                color: T.COLOR_PRIMARY,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )),
          child: CupertinoSettings(items: <Widget>[
            const CSHeader('Příspěvky'),
            CSControl(
              nameWidget: Text('Kompaktní zobrazení'),
              contentWidget: CupertinoSwitch(value: false),
              style: postsStyle,
            ),
            CSDescription(
              'Kompaktní zobrazení je zobrazení obrázků po stranách pokud to obsah příspěvku dovoluje (nedojde tak k narušení kontextu).',
            ),
            CSHeader('Úvodní obrazovka'),
            CSSelection<int>(
              items: const <CSSelectionItem<int>>[
                CSSelectionItem<int>(text: 'Historie (vše)', value: 0),
                CSSelectionItem<int>(text: 'Historie (nepřečtené)', value: 1),
                CSSelectionItem<int>(text: 'Sledované (vše)', value: 2),
                CSSelectionItem<int>(text: 'Sledované (nepřečtené)', value: 3),
              ],
              onSelected: (index) {
                print(index);
              },
              currentSelection: 0,
            ),
            const CSHeader(''),
            CSButton(
              CSButtonType.DEFAULT,
              L.SETTINGS_BUGREPORT,
              () => PlatformTheme.prefillGithubIssue(L.SETTINGS_BUGREPORT_TITLE),
              style: bugreportStyle,
            ),
            CSButton(CSButtonType.DEFAULT, "O aplikaci", () {
              print("It works!");
            }, style: aboutStyle),
            CSButton(
              CSButtonType.DEFAULT,
              "Patroni",
              () {
                print("It works!");
              },
              style: patronsStyle,
            ),
            const CSHeader(''),
            CSButton(CSButtonType.DESTRUCTIVE, L.GENERAL_LOGOUT, () {
              ApiController().logout();
              Navigator.of(context, rootNavigator: true).pushNamed('/login');
            }),
            Visibility(
                visible: FyxApp.isDev,
                child: CSButton(CSButtonType.DESTRUCTIVE, '${L.GENERAL_LOGOUT} (bez resetu)', () {
                  ApiController().logout(removeAuthrorization: false);
                  Navigator.of(context, rootNavigator: true).pushNamed('/login');
                })),
            CSDescription('Verze: ${version}')
          ]));
    });
  }
}
