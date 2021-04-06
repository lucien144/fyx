import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _compactMode;
  bool _underTheHood;
  bool _autocorrect;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _compactMode = MainRepository().settings.useCompactMode;
    _underTheHood = false;
    _autocorrect = MainRepository().settings.useAutocorrect;
    AnalyticsProvider().setScreen('Settings', 'SettingsPage');
  }

  @override
  Widget build(BuildContext context) {
    CSWidgetStyle postsStyle = const CSWidgetStyle(icon: const Icon(Icons.view_compact, color: Colors.black54));
    CSWidgetStyle autocorrectStyle = const CSWidgetStyle(icon: const Icon(Icons.spellcheck, color: Colors.black54));
    CSWidgetStyle bugreportStyle = const CSWidgetStyle(icon: const Icon(Icons.bug_report, color: Colors.black54));
    CSWidgetStyle aboutStyle = const CSWidgetStyle(icon: const Icon(Icons.info, color: Colors.black54));
    CSWidgetStyle patronsStyle = const CSWidgetStyle(icon: const Icon(Icons.stars, color: Colors.black54));
    CSWidgetStyle termsStyle = const CSWidgetStyle(icon: const Icon(Icons.account_balance, color: Colors.black54));

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
            nameWidget: Text('Autocorrect'),
            contentWidget: CupertinoSwitch(
                value: _autocorrect,
                onChanged: (bool value) {
                  setState(() => _autocorrect = value);
                  MainRepository().settings.useAutocorrect = value;
                }),
            style: autocorrectStyle,
          ),
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
              CSSelectionItem<DefaultView>(text: 'Poslední stav', value: DefaultView.latest),
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
          CSHeader('Paměť'),
          CSControl(
            nameWidget: Text('Blokovaných uživatelů'),
            contentWidget: ValueListenableBuilder(
                valueListenable: MainRepository().settings.box.listenable(keys: ['blockedUsers']),
                builder: (BuildContext context, value, Widget child) {
                  return Text(MainRepository().settings.blockedUsers.length.toString());
                }),
          ),
          CSControl(
            nameWidget: Text('Skrytých příspěvků'),
            contentWidget: ValueListenableBuilder(
                valueListenable: MainRepository().settings.box.listenable(keys: ['blockedPosts']),
                builder: (BuildContext context, value, Widget child) {
                  return Text(MainRepository().settings.blockedPosts.length.toString());
                }),
          ),
          CSControl(
            nameWidget: Text('Skrytých mailů'),
            contentWidget: ValueListenableBuilder(
                valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails']),
                builder: (BuildContext context, value, Widget child) {
                  return Text(MainRepository().settings.blockedMails.length.toString());
                }),
          ),
          CSButton(CSButtonType.DESTRUCTIVE, 'Reset', () {
            MainRepository().settings.resetBlockedContent();
            PlatformTheme.success(L.SETTINGS_CACHE_RESET);
            AnalyticsProvider().logEvent('resetBlockedContent');
          }),
          const CSHeader('Informace'),
          // CSButton(
          //   CSButtonType.DEFAULT,
          //   L.BACKERS,
          //   () => Navigator.of(context).pushNamed('/settings/info', arguments: InfoPageSettings(L.BACKERS, 'https://raw.githubusercontent.com/lucien144/fyx/develop/BACKERS.md')),
          //   style: patronsStyle,
          // ),
          CSButton(CSButtonType.DEFAULT, L.ABOUT,
              () => Navigator.of(context).pushNamed('/settings/info', arguments: InfoPageSettings(L.ABOUT, 'https://raw.githubusercontent.com/lucien144/fyx/develop/ABOUT.md')),
              style: aboutStyle),
          CSButton(
            CSButtonType.DEFAULT,
            L.SETTINGS_BUGREPORT,
            () {
              PlatformTheme.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials.nickname);
              AnalyticsProvider().logEvent('reportBug');
            },
            style: bugreportStyle,
          ),
          CSButton(
            CSButtonType.DEFAULT,
            L.TERMS,
            () {
              PlatformTheme.openLink('https://nyx.cz/terms');
              AnalyticsProvider().logEvent('openTerms');
            },
            style: termsStyle,
          ),
          const CSHeader(''),
          CSButton(CSButtonType.DESTRUCTIVE, L.GENERAL_LOGOUT, () {
            ApiController().logout();
            Navigator.of(context, rootNavigator: true).pushNamed('/login');
            AnalyticsProvider().logEvent('logout');
          }),
          Visibility(
              visible: FyxApp.isDev,
              child: CSButton(CSButtonType.DESTRUCTIVE, '${L.GENERAL_LOGOUT} (bez resetu)', () {
                ApiController().logout(removeAuthrorization: false);
                Navigator.of(context, rootNavigator: true).pushNamed('/login');
              })),
          CSDescription('Verze: $version'),
          GestureDetector(child: CSDescription('Nahlídnout pod kapotu.'), onTap: () => setState(() => _underTheHood = !_underTheHood)),
          Visibility(
            visible: _underTheHood,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    child: CSDescription('API token: ${MainRepository().credentials.token}'),
                    onTap: () => Clipboard.setData(ClipboardData(text: MainRepository().credentials.token))),
                FutureBuilder<String>(
                    future: _firebaseMessaging.getToken(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return GestureDetector(
                            child: CSDescription('FCM token: ${snapshot.data.substring(0, 30)}...'), onTap: () => Clipboard.setData(ClipboardData(text: snapshot.data)));
                      }
                      if (snapshot.hasError) {
                        return CSDescription('FCM token: error :(');
                      }
                      return CSDescription('FCM token: načítám...');
                    }),
              ],
            ),
          ),
        ]));
  }
}
