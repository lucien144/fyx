import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyx/FyxApp.dart';
import 'package:fyx/components/WhatsNew.dart';
import 'package:fyx/components/premium_feature.dart';
import 'package:fyx/components/premium_feature_bottom_sheet.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/controllers/drafts_service.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Settings.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/LaunchModeEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:fyx/model/enums/premium_feature_enum.dart';
import 'package:fyx/pages/InfoPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

enum CacheKeys { images, gifs, videos, other }

class _SettingsScreenState extends State<SettingsScreen> {
  Map cacheUsage = {CacheKeys.images: 0.0, CacheKeys.gifs: 0.0, CacheKeys.videos: 0.0, CacheKeys.other: 0.0};

  bool _compactMode = false;
  bool _markdown = false;
  bool _bulkActions = true;
  bool _autocorrect = false;
  bool _quickRating = true;
  bool _useFyxImageCache = false;
  bool _emptyingCache = false;
  Future<Map<CacheKeys, double>> _cacheSize = Future.value({});
  DefaultView _defaultView = DefaultView.latest;
  FirstUnreadEnum _firstUnread = FirstUnreadEnum.button;
  LaunchModeEnum _linksMode = LaunchModeEnum.externalApplication;

  int $showDebug = 5;

  @override
  void initState() {
    super.initState();
    _compactMode = MainRepository().settings.useCompactMode;
    _markdown = MainRepository().settings.useMarkdown;
    _bulkActions = MainRepository().settings.useBulkActions;
    _autocorrect = MainRepository().settings.useAutocorrect;
    _defaultView = MainRepository().settings.defaultView;
    _firstUnread = MainRepository().settings.firstUnread;
    _linksMode = MainRepository().settings.linksMode;
    _quickRating = MainRepository().settings.quickRating;
    _useFyxImageCache = MainRepository().settings.useFyxImageCache;
    _cacheSize = _getCacheSize();
    AnalyticsProvider().setScreen('Settings', 'SettingsPage');
  }

  SettingsTile _firstUnreadFactory(String label, FirstUnreadEnum value, {Widget? description}) {
    return SettingsTile(
      title: Text(label),
      trailing: _firstUnread == value ? Icon(CupertinoIcons.check_mark) : null,
      description: description,
      onPressed: (_) {
        setState(() => _firstUnread = value);
        MainRepository().settings.firstUnread = value;
      },
    );
  }

  SettingsTile _defaultViewFactory(String label, DefaultView value) {
    return SettingsTile(
      title: Text(label),
      trailing: _defaultView == value ? Icon(CupertinoIcons.check_mark) : null,
      onPressed: (_) {
        setState(() => _defaultView = value);
        MainRepository().settings.defaultView = value;
      },
    );
  }

  SettingsTile _linksModeFactory(String label, LaunchModeEnum value) {
    return SettingsTile(
      title: Text(label),
      trailing: _linksMode == value ? Icon(CupertinoIcons.check_mark) : null,
      onPressed: (_) {
        setState(() => _linksMode = value);
        MainRepository().settings.linksMode = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            automaticBackgroundVisibility: false,
            backgroundColor: colors.barBackground,
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
          child: SettingsList(
            lightTheme: SettingsThemeData(
                settingsSectionBackground: colors.barBackground,
                settingsListBackground: colors.background,
                settingsTileTextColor: colors.text,
                tileHighlightColor: colors.primary.withOpacity(0.1),
                trailingTextColor: colors.grey,
                leadingIconsColor: colors.grey,
                dividerColor: colors.background),
            sections: [
              SettingsSection(
                title: Text('Obecné'),
                tiles: <AbstractSettingsTile>[
                  SettingsTile.switchTile(
                    onToggle: (bool value) {
                      setState(() => _autocorrect = value);
                      MainRepository().settings.useAutocorrect = value;
                    },
                    initialValue: _autocorrect,
                    leading: Icon(Icons.spellcheck, color: colors.grey),
                    title: Text('Autocorrect'),
                  ),
                  SettingsTile.switchTile(
                      onToggle: (bool value) {
                        setState(() => _quickRating = value);
                        MainRepository().settings.quickRating = value;
                      },
                      initialValue: _quickRating,
                      leading: Icon(MdiIcons.thumbsUpDown, color: colors.grey),
                      title: Text('Rychlé hodnocení')),
                  CustomSettingsTile(
                    child: PremiumFeature(
                      feature: PremiumFeatureEnum.markdown,
                      child: SettingsTile.switchTile(
                        onToggle: (bool value) {
                          setState(() => _markdown = value);
                          MainRepository().settings.useMarkdown = value;
                        },
                        initialValue: _markdown,
                        leading: Icon(MdiIcons.languageMarkdown, color: colors.grey),
                        title: Text('Markdown'),
                      ),
                    ),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (bool value) {
                      setState(() => _bulkActions = value);
                      MainRepository().settings.useBulkActions = value;
                    },
                    initialValue: _bulkActions,
                    leading: Icon(MdiIcons.checkboxMultipleMarked, color: colors.grey),
                    title: Text('Hromadné akce'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (bool value) {
                      setState(() => _compactMode = value);
                      MainRepository().settings.useCompactMode = value;
                    },
                    initialValue: _compactMode,
                    leading: Icon(Icons.view_compact, color: colors.grey),
                    title: Text('Kompaktní zobrazení'),
                    description: Text(
                      'Kompaktní zobrazení: zobrazuje obrázky po stranách pokud to obsah příspěvku dovoluje (nedojde tak k narušení kontextu).'
                      '\n'
                      'Rychlé hodnocení: možnost hodnotit příspěvek na dvojklik (double-tap).',
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('První nepřečtený'),
                tiles: <SettingsTile>[
                  _firstUnreadFactory('Vypnuto', FirstUnreadEnum.off),
                  _firstUnreadFactory('Zobrazovat tlačítko', FirstUnreadEnum.button),
                  _firstUnreadFactory('Automaticky odskočit', FirstUnreadEnum.autoscroll,
                      description: Text('Funguje pouze na prvních 100 nepřečtených.')),
                ],
              ),
              SettingsSection(
                title: Text('Výchozí obrazovka'),
                tiles: <SettingsTile>[
                  _defaultViewFactory('Poslední stav', DefaultView.latest),
                  _defaultViewFactory('Historie (vše)', DefaultView.history),
                  _defaultViewFactory('Historie (nepřečtené)', DefaultView.historyUnread),
                  _defaultViewFactory('Sledované (vše)', DefaultView.bookmarks),
                  _defaultViewFactory('Sledované (nepřečtené)', DefaultView.bookmarksUnread),
                ],
              ),
              SettingsSection(
                title: Text('Vzhled'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    title: Text('Barevný režim'),
                    value: Text((() {
                      switch (MainRepository().settings.theme) {
                        case ThemeEnum.light:
                          return 'Světlý';

                        case ThemeEnum.dark:
                          return 'Tmavý';

                        case ThemeEnum.system:
                          return 'Podle systému';
                      }
                    })()),
                    onPressed: (context) => Navigator.of(context).pushNamed('/settings/design'),
                  ),
                  SettingsTile.navigation(
                    title: Text('Velikost písma'),
                    value: Text('${MainRepository().settings.fontSize.toInt().toString()}pt'),
                    onPressed: (context) => Navigator.of(context).pushNamed('/settings/design'),
                  ),
                  SettingsTile.navigation(
                    title: Text('Skin'),
                    value: Text(Skin.of(context).skins.firstWhere((skin) => skin.id == MainRepository().settings.skin).name),
                    onPressed: (context) => Navigator.of(context).pushNamed('/settings/design'),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('Otevírání odkazů'),
                tiles: <SettingsTile>[
                  //_linksModeFactory('Podle nastavení systému', LaunchModeEnum.platformDefault),
                  _linksModeFactory('Otevírat v externí aplikaci', LaunchModeEnum.externalApplication),
                  _linksModeFactory('Otevírat ve Fyxu', LaunchModeEnum.inAppWebView),
                ],
              ),
              SettingsSection(
                title: Text('Paměť'),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                      onToggle: (bool value) {
                        setState(() => _useFyxImageCache = value);
                        MainRepository().settings.useFyxImageCache = value;
                      },
                      initialValue: _useFyxImageCache,
                      title: Text('Zmenšovat obrázky')),
                  SettingsTile(
                    title: Text('Blokovaných uživatelů'),
                    trailing: ValueListenableBuilder(
                        valueListenable: MainRepository().settings.box.listenable(keys: ['blockedUsers']),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            MainRepository().settings.blockedUsers.length.toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                    title: Text('Skrytých příspěvků'),
                    trailing: ValueListenableBuilder(
                        valueListenable: MainRepository().settings.box.listenable(keys: ['blockedPosts']),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            MainRepository().settings.blockedPosts.length.toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                    title: Text('Skryté pošty'),
                    trailing: ValueListenableBuilder(
                        valueListenable: MainRepository().settings.box.listenable(keys: ['blockedMails']),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            MainRepository().settings.blockedMails.length.toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                    title: Text('Peprných diskuzí'),
                    trailing: ValueListenableBuilder(
                        valueListenable: MainRepository().settings.box.listenable(keys: ['nsfwDiscussionList']),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            MainRepository().settings.nsfwDiscussionList.length.toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                    title: Text('Rozepsaných nových postů'),
                    trailing: ValueListenableBuilder(
                        valueListenable: DraftsService().box.listenable(),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            DraftsService().countDiscussions().toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                    title: Text('Rozepsaných odpovědí'),
                    trailing: ValueListenableBuilder(
                        valueListenable: DraftsService().box.listenable(),
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            DraftsService().countPosts().toString(),
                            style: TextStyle(color: colors.text, fontSize: Settings().fontSize),
                          );
                        }),
                  ),
                  SettingsTile(
                      title: Text('Resetovat', style: TextStyle(color: colors.danger), textAlign: TextAlign.center),
                      onPressed: (_) {
                        MainRepository().settings.resetBlockedContent();
                        MainRepository().settings.resetNsfwDiscussion();
                        DraftsService().flush();
                        T.success(L.SETTINGS_CACHE_RESET, bg: colors.success);
                        AnalyticsProvider().logEvent('resetBlockedContent');
                      },
                      description: Text(
                          'Zmenšovat obrázky - zmenšuje obrázky před stažením a předchází tak pádům aplikavce. V určitých případech ale může snižovat FPS.')),
                ],
              ),
              CustomSettingsSection(
                  child: FutureBuilder<Map>(
                future: _cacheSize,
                builder: (context, snapshot) {
                  var tiles = [
                    SettingsTile(
                      title: Text('Obrázky'),
                      trailing: Text(
                        '~${snapshot.data?[CacheKeys.images].round() ?? 0} MB',
                        style: TextStyle(color: colors.text),
                      ),
                    ),
                    SettingsTile(
                      title: Text('Gify'),
                      trailing: Text('~${snapshot.data?[CacheKeys.gifs].round() ?? 0} MB', style: TextStyle(color: colors.text)),
                    ),
                    // SettingsTile(
                    //   title: Text('Videa'),
                    //   trailing: Text('${snapshot.data?[CacheKeys.videos].round() ?? 0}M'),
                    // ),
                    SettingsTile(
                      title: Text('Ostatní'),
                      trailing: Text('~${snapshot.data?[CacheKeys.other].round() ?? 0} MB', style: TextStyle(color: colors.text)),
                    ),
                    SettingsTile(
                        title: Text(_emptyingCache ? 'Mažu...' : 'Smazat',
                            style: TextStyle(color: _emptyingCache ? colors.danger : colors.danger), textAlign: TextAlign.center),
                        onPressed: (_) async {
                          if (_emptyingCache) {
                            return;
                          }

                          setState(() => _emptyingCache = true);
                          try {
                            await _emptyCache();
                          } catch (error) {
                            // T.error('👎 Úložiště se nepodařilo promazat.', bg: colors.danger);
                            // LogService.captureError(error);
                          } finally {
                            // Production is trying to delete recursively the /Cache folder which fails.
                            // There's no easy fix or workaround for now.
                            T.success('👍 Úložiště promazáno.', bg: colors.success);
                            setState(() {
                              _emptyingCache = false;
                              _cacheSize = _getCacheSize();
                            });
                            AnalyticsProvider().logEvent('emptyCache');
                          }
                        })
                  ];

                  if (snapshot.hasError) {
                    tiles = [
                      SettingsTile(
                        title: Text('Nastala chyba, nelze spočítat.'),
                      )
                    ];
                    LogService.captureError(snapshot.error);
                  }

                  return Stack(children: [
                    Opacity(opacity: snapshot.hasData || snapshot.hasError ? 1 : 0.5, child: SettingsSection(title: Text('Úložiště'), tiles: tiles)),
                    Visibility(visible: !snapshot.hasData && !snapshot.hasError, child: Positioned.fill(child: CupertinoActivityIndicator()))
                  ]);
                },
              )),
              SettingsSection(title: Text('Informace'), tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.lock, color: colors.grey),
                  title: Text('Funkce pro podporovatele'),
                  onPressed: (_) => showCupertinoModalBottomSheet(
                      context: context,
                      backgroundColor: colors.barBackground,
                      barrierColor: colors.dark.withOpacity(0.5),
                      builder: (BuildContext context) => PremiumFeatureBottomSheet(
                            preview: true,
                          )),
                ),
                // SettingsTile.navigation(
                //   leading: Icon(Icons.volunteer_activism, color: colors.grey),
                //   title: Text(L.BACKERS),
                //   onPressed: (_) => Navigator.of(context).pushNamed('/settings/info',
                //       arguments: InfoPageSettings(L.BACKERS, 'https://raw.githubusercontent.com/lucien144/fyx/develop/BACKERS.md')),
                // ),
                SettingsTile.navigation(
                  leading: Icon(Icons.info, color: colors.grey),
                  title: Text(L.ABOUT),
                  onPressed: (_) => Navigator.of(context).pushNamed('/settings/info',
                      arguments: InfoPageSettings(L.ABOUT, 'https://raw.githubusercontent.com/lucien144/fyx/develop/ABOUT.md')),
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.bug_report, color: colors.grey),
                  title: Text(L.SETTINGS_BUGREPORT),
                  onPressed: (_) {
                    T.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials!.nickname);
                    AnalyticsProvider().logEvent('reportBug');
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.gavel, color: colors.grey),
                  title: Text(L.TERMS),
                  onPressed: (_) {
                    T.openLink('https://nyx.cz/terms', mode: _linksMode);
                    AnalyticsProvider().logEvent('openTerms');
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(MdiIcons.star, color: colors.grey),
                  title: Text('Co je nového v této verzi?'),
                  onPressed: (_) {
                    showCupertinoModalBottomSheet(
                      context: context,
                      expand: false,
                      builder: (context) => WhatsNew(),
                      backgroundColor: colors.barBackground,
                      barrierColor: colors.dark.withOpacity(0.5),
                    );
                    AnalyticsProvider().logEvent('openWhatsNew');
                  },
                )
              ]),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: Text(
                      L.GENERAL_LOGOUT,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.danger),
                    ),
                    onPressed: (_) {
                      ApiController().logout();
                      Navigator.of(context, rootNavigator: true).pushNamed('/login');
                      AnalyticsProvider().logEvent('logout');
                    },
                  ),
                  if (FyxApp.isDev)
                    SettingsTile(
                      title: Text(
                        '${L.GENERAL_LOGOUT} (bez resetu)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.danger),
                      ),
                      onPressed: (_) {
                        ApiController().logout(removeAuthrorization: false);
                        Navigator.of(context, rootNavigator: true).pushNamed('/login');
                      },
                    )
                ],
              ),
              CustomSettingsSection(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => $showDebug--),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20 + MediaQuery.viewPaddingOf(context).bottom),
                    child: Text(
                      'Verze: $version ${$showDebug <= 3 ? $showDebug : ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.disabled, fontFamily: 'JetBrainsMono', fontSize: 13),
                    ),
                  ),
                ),
              ),
              if ($showDebug <= 0)
                CustomSettingsSection(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FutureBuilder(
                            future: ApiController().getCredentials(),
                            builder: (context, AsyncSnapshot<Credentials?> snapshot) {
                              var token = 'Loading...';
                              var fcmToken = 'Loading...';
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                default:
                                  if (snapshot.hasError) {
                                    fcmToken = snapshot.error.toString();
                                    token = snapshot.error.toString();
                                  } else {
                                    fcmToken = snapshot.data?.fcmToken ?? 'Invalid';
                                    token = snapshot.data?.token ?? 'Invalid';
                                  }
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      var data = ClipboardData(text: fcmToken);
                                      Clipboard.setData(data).then((_) {
                                        T.success(L.TOAST_COPIED, bg: colors.success);
                                      });
                                    },
                                    child: Text(
                                      'FCM token: ${fcmToken}...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: colors.disabled, fontFamily: 'JetBrainsMono', fontSize: 13),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      var data = ClipboardData(text: token);
                                      Clipboard.setData(data).then((_) {
                                        T.success(L.TOAST_COPIED, bg: colors.success);
                                      });
                                    },
                                    child: Text(
                                      'Bearer: ${token}...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: colors.disabled, fontFamily: 'JetBrainsMono', fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  // https://stackoverflow.com/questions/62117279/how-to-get-application-cache-size-in-flutter
  Future<Map<CacheKeys, double>> _getCacheSize() async {
    Directory tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      _getSize(tempDir);
      return cacheUsage.map((key, value) => MapEntry(key, value / pow(1024, 2)));
    }
    return Future.value({CacheKeys.images: 0.0, CacheKeys.gifs: 0.0, CacheKeys.videos: 0.0, CacheKeys.other: 0.0});
  }

  void _getSize(FileSystemEntity file) {
    if (file is File) {
      if (RegExp(r'\.(jpg|jpeg|png|webp)$', caseSensitive: false).hasMatch(file.path)) {
        cacheUsage[CacheKeys.images] += file.lengthSync();
      } else if (RegExp(r'\.(gif|gifv)$', caseSensitive: false).hasMatch(file.path)) {
        cacheUsage[CacheKeys.gifs] += file.lengthSync();
      } else if (RegExp(r'\.(mp4|webm|mkv)$', caseSensitive: false).hasMatch(file.path)) {
        cacheUsage[CacheKeys.videos] += file.lengthSync();
      } else {
        cacheUsage[CacheKeys.other] += file.lengthSync();
      }
    } else if (file is Directory) {
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        _getSize(child);
      }
    }
  }

  Future<FileSystemEntity> _emptyCache() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.delete(recursive: true);
  }
}
