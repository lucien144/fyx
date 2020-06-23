import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Settings.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _compactMode;

  @override
  void initState() {
    super.initState();

    _compactMode = MainRepository().settings.useCompactMode;
  }

  @override
  Widget build(BuildContext context) {
    CSWidgetStyle postsStyle = const CSWidgetStyle(icon: const Icon(Icons.view_compact, color: Colors.black54));
    CSWidgetStyle bugreportStyle = const CSWidgetStyle(icon: const Icon(Icons.bug_report, color: Colors.black54));
    CSWidgetStyle aboutStyle = const CSWidgetStyle(icon: const Icon(Icons.info, color: Colors.black54));
    CSWidgetStyle patronsStyle = const CSWidgetStyle(icon: const Icon(Icons.stars, color: Colors.black54));

    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';

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
            contentWidget: CupertinoSwitch(
                value: _compactMode,
                onChanged: (bool value) {
                  setState(() => _compactMode = value);
                  MainRepository().settings.useCompactMode = value;
                }),
            style: postsStyle,
          ),
          CSDescription(
            'Kompaktní zobrazení je zobrazení obrázků po stranách pokud to obsah příspěvku dovoluje (nedojde tak k narušení kontextu).',
          ),
          CSHeader('Úvodní obrazovka'),
          CSSelection<DefaultView>(
            items: const <CSSelectionItem<DefaultView>>[
              CSSelectionItem<DefaultView>(text: 'Historie (vše)', value: DefaultView.history),
              CSSelectionItem<DefaultView>(text: 'Historie (nepřečtené)', value: DefaultView.historyUnread),
              CSSelectionItem<DefaultView>(text: 'Sledované (vše)', value: DefaultView.bookmarks),
              CSSelectionItem<DefaultView>(text: 'Sledované (nepřečtené)', value: DefaultView.bookmarksUnread),
            ],
            onSelected: (index) {
              MainRepository().settings.defaultView = index;
            },
            currentSelection: MainRepository().settings.defaultView,
          ),
          const CSHeader(''),
          CSButton(
            CSButtonType.DEFAULT,
            L.BACKERS,
            () => Navigator.of(context)
                .pushNamed('/settings/info', arguments: InfoPageSettings(L.BACKERS, 'https://raw.githubusercontent.com/lucien144/fyx/feature/settings/BACKERS.md')),
            style: patronsStyle,
          ),
          CSButton(
              CSButtonType.DEFAULT,
              L.ABOUT,
              () => Navigator.of(context)
                  .pushNamed('/settings/info', arguments: InfoPageSettings(L.ABOUT, 'https://raw.githubusercontent.com/lucien144/fyx/feature/settings/ABOUT.md')),
              style: aboutStyle),
          CSButton(
            CSButtonType.DEFAULT,
            L.SETTINGS_BUGREPORT,
            () => PlatformTheme.prefillGithubIssue(L.SETTINGS_BUGREPORT_TITLE),
            style: bugreportStyle,
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
  }
}