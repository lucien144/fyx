import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:fyx/model/provider/ThemeModel.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _compactMode = false;
  bool _underTheHood = false;
  bool _autocorrect = false;
  DefaultView _defaultView = DefaultView.latest;
  ThemeEnum _theme = ThemeEnum.light;
  FirstUnreadEnum _firstUnread = FirstUnreadEnum.button;

  @override
  void initState() {
    super.initState();
    _compactMode = MainRepository().settings.useCompactMode;
    _underTheHood = false;
    _autocorrect = MainRepository().settings.useAutocorrect;
    _defaultView = MainRepository().settings.defaultView;
    _theme = MainRepository().settings.theme;
    _firstUnread = MainRepository().settings.firstUnread;
    AnalyticsProvider().setScreen('Settings', 'SettingsPage');
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    CSWidgetStyle postsStyle = CSWidgetStyle(icon: Icon(Icons.view_compact, color: colors.text.withOpacity(0.38)));
    CSWidgetStyle autocorrectStyle = CSWidgetStyle(icon: Icon(Icons.spellcheck, color: colors.text.withOpacity(0.38)));
    CSWidgetStyle bugreportStyle = CSWidgetStyle(icon: Icon(Icons.bug_report, color: colors.text.withOpacity(0.38)));
    CSWidgetStyle aboutStyle = CSWidgetStyle(icon: Icon(Icons.info, color: colors.text.withOpacity(0.38)));
    CSWidgetStyle patronsStyle = CSWidgetStyle(icon: Icon(Icons.volunteer_activism, color: colors.text.withOpacity(0.38)));
    CSWidgetStyle termsStyle = CSWidgetStyle(icon: Icon(Icons.gavel, color: colors.text.withOpacity(0.38)));

    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text(
              L.SETTINGS,
              style: TextStyle(color: colors.text),
            ),
            leading: CupertinoNavigationBarBackButton(
              color: colors.primary,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )),
        child: CupertinoScrollbar(
          child: CupertinoSettings(items: <Widget>[
            const CSHeader('Příspěvky'),
            CSControl(
              nameWidget: Text(
                'Autocorrect',
                style: TextStyle(color: colors.text),
              ),
              contentWidget: CupertinoSwitch(
                  value: _autocorrect,
                  onChanged: (bool value) {
                    setState(() => _autocorrect = value);
                    MainRepository().settings.useAutocorrect = value;
                  }),
              style: autocorrectStyle,
            ),
            CSControl(
              nameWidget: Text(
                'Kompaktní zobrazení',
                style: TextStyle(color: colors.text),
              ),
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
            CSHeader('První nepřečtený'),
            CSSelection<FirstUnreadEnum>(
              items: const <CSSelectionItem<FirstUnreadEnum>>[
                CSSelectionItem<FirstUnreadEnum>(text: 'Vypnuto', value: FirstUnreadEnum.off),
                CSSelectionItem<FirstUnreadEnum>(text: 'Zobrazovat tlačítko', value: FirstUnreadEnum.button),
                CSSelectionItem<FirstUnreadEnum>(text: 'Automaticky odskočit', value: FirstUnreadEnum.autoscroll),
              ],
              onSelected: (value) {
                setState(() => _firstUnread = value);
                MainRepository().settings.firstUnread = value;
              },
              currentSelection: _firstUnread,
            ),
            CSDescription(
              'Pokud má diskuze více jak 100 nepřečtených, Fyx odskočí pouze na 100. příspěvek.',
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
                setState(() => _defaultView = index);
                MainRepository().settings.defaultView = index;
              },
              currentSelection: _defaultView,
            ),
            CSHeader('Barevný režim'),
            CSSelection<ThemeEnum>(
              items: const <CSSelectionItem<ThemeEnum>>[
                CSSelectionItem<ThemeEnum>(text: 'Světlý', value: ThemeEnum.light),
                CSSelectionItem<ThemeEnum>(text: 'Tmavý', value: ThemeEnum.dark),
                CSSelectionItem<ThemeEnum>(text: 'Podle systému', value: ThemeEnum.system),
              ],
              onSelected: (theme) {
                setState(() => _theme = theme);
                MainRepository().settings.theme = theme;
                Provider.of<ThemeModel>(context, listen: false).setTheme(theme);
              },
              currentSelection: _theme,
            ),
            CSHeader('Paměť'),
            CSControl(
              nameWidget: Text(
                'Blokovaných uživatelů',
                style: TextStyle(color: colors.text),
              ),
              contentWidget: ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['blockedUsers']),
                  builder: (BuildContext context, value, Widget? child) {
                    return Text(
                      MainRepository().settings.blockedUsers.length.toString(),
                      style: TextStyle(color: colors.text),
                    );
                  }),
            ),
            CSControl(
              nameWidget: Text(
                'Skrytých příspěvků',
                style: TextStyle(color: colors.text),
              ),
              contentWidget: ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['blockedPosts']),
                  builder: (BuildContext context, value, Widget? child) {
                    return Text(
                      MainRepository().settings.blockedPosts.length.toString(),
                      style: TextStyle(color: colors.text),
                    );
                  }),
            ),
            CSControl(
              nameWidget: Text(
                'Skrytých mailů',
                style: TextStyle(color: colors.text),
              ),
              contentWidget: ValueListenableBuilder(
                  valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails']),
                  builder: (BuildContext context, value, Widget? child) {
                    return Text(
                      MainRepository().settings.blockedMails.length.toString(),
                      style: TextStyle(color: colors.text),
                    );
                  }),
            ),
            CSButton(CSButtonType.DESTRUCTIVE, 'Reset', () {
              MainRepository().settings.resetBlockedContent();
              T.success(L.SETTINGS_CACHE_RESET, bg: colors.success);
              AnalyticsProvider().logEvent('resetBlockedContent');
            }),
            const CSHeader('Informace'),
            CSButton(
              CSButtonType.DEFAULT,
              L.BACKERS,
              () => Navigator.of(context).pushNamed('/settings/info',
                  arguments: InfoPageSettings(L.BACKERS, 'https://raw.githubusercontent.com/lucien144/fyx/develop/BACKERS.md')),
              style: patronsStyle,
            ),
            CSButton(
                CSButtonType.DEFAULT,
                L.ABOUT,
                () => Navigator.of(context).pushNamed('/settings/info',
                    arguments: InfoPageSettings(L.ABOUT, 'https://raw.githubusercontent.com/lucien144/fyx/develop/ABOUT.md')),
                style: aboutStyle),
            CSButton(
              CSButtonType.DEFAULT,
              L.SETTINGS_BUGREPORT,
              () {
                T.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials!.nickname);
                AnalyticsProvider().logEvent('reportBug');
              },
              style: bugreportStyle,
            ),
            CSButton(
              CSButtonType.DEFAULT,
              L.TERMS,
              () {
                T.openLink('https://nyx.cz/terms');
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
                      child: CSDescription('API token: ${MainRepository().credentials!.token}'),
                      onTap: () => Clipboard.setData(ClipboardData(text: MainRepository().credentials!.token))),
                  FutureBuilder<String?>(
                      future: FirebaseMessaging.instance.getToken(),
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return GestureDetector(
                              child: CSDescription('FCM token: ${snapshot.data!.substring(0, 30)}...'),
                              onTap: () => Clipboard.setData(ClipboardData(text: snapshot.data)));
                        }
                        if (snapshot.hasError) {
                          return CSDescription('FCM token: error :(');
                        }
                        return CSDescription('FCM token: načítám...');
                      }),
                ],
              ),
            ),
          ]),
        ));
  }
}
