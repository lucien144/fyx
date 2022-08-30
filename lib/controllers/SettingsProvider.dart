import 'package:fyx/model/Settings.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/LaunchModeEnum.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsProvider {
  static final SettingsProvider _singleton = SettingsProvider._internal();
  late Settings _settings;
  late Box<dynamic> _box;

  Box<dynamic> get box => _box;

  ThemeEnum get theme => _settings.theme;
  set theme(ThemeEnum theme) {
    _box.put('theme', theme);
    _settings.theme = theme;
  }

  SkinEnum get skin => _settings.skin;
  set skin(SkinEnum skin) {
    _box.put('skin', skin);
    _settings.skin = skin;
  }

  double get fontSize => _settings.fontSize;
  set fontSize(double fontSize) {
    _box.put('fontSize', fontSize);
    _settings.fontSize = fontSize;
  }

  DefaultView get defaultView => _settings.defaultView;
  set defaultView(DefaultView view) {
    _box.put('defaultView', view);
    _settings.defaultView = view;
  }

  DefaultView get latestView => _settings.latestView;
  set latestView(DefaultView view) {
    _box.put('latestView', view);
    _settings.latestView = view;
  }

  FirstUnreadEnum get firstUnread => _settings.firstUnread;
  set firstUnread(FirstUnreadEnum value) {
    _box.put('firstUnread', value);
    _settings.firstUnread = value;
  }

  bool get useCompactMode => _settings.useCompactMode;
  set useCompactMode(bool mode) {
    _box.put('useCompactMode', mode);
    _settings.useCompactMode = mode;
  }

  bool get useAutocorrect => _settings.useAutocorrect;
  set useAutocorrect(bool autocorrect) {
    _box.put('useAutocorrect', autocorrect);
    _settings.useAutocorrect = autocorrect;
  }

  LaunchModeEnum get linksMode => _settings.linksMode;
  set linksMode(LaunchModeEnum mode) {
    _box.put('linksMode', mode);
    _settings.linksMode = mode;
  }

  List get blockedMails => _box.get('blockedMails', defaultValue: Settings().blockedMails);

  List get blockedPosts => _box.get('blockedPosts', defaultValue: Settings().blockedPosts);

  List get blockedUsers => _box.get('blockedUsers', defaultValue: Settings().blockedUsers);

  factory SettingsProvider() {
    return _singleton;
  }

  SettingsProvider._internal();

  Future<SettingsProvider> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DefaultViewAdapter());
    Hive.registerAdapter(ThemeEnumAdapter());
    Hive.registerAdapter(FirstUnreadEnumAdapter());
    Hive.registerAdapter(SkinEnumAdapter());
    Hive.registerAdapter(LaunchModeEnumAdapter());
    _box = await Hive.openBox('settings');

    _settings = new Settings();
    _settings.theme = _box.get('theme', defaultValue: Settings().theme);
    _settings.fontSize = _box.get('fontSize', defaultValue: Settings().fontSize);
    _settings.defaultView = _box.get('defaultView', defaultValue: Settings().defaultView);
    _settings.latestView = _box.get('latestView', defaultValue: Settings().latestView);
    _settings.useCompactMode = _box.get('useCompactMode', defaultValue: Settings().useCompactMode);
    _settings.useAutocorrect = _box.get('useAutocorrect', defaultValue: Settings().useAutocorrect);
    _settings.firstUnread = _box.get('firstUnread', defaultValue: Settings().firstUnread);
    _settings.skin = _box.get('skin', defaultValue: Settings().skin);
    _settings.linksMode = _box.get('linksMode', defaultValue: Settings().linksMode);

    return _singleton;
  }

  bool isPostBlocked(int postId) => _box.get('blockedPosts', defaultValue: Settings().blockedPosts).indexOf(postId) >= 0;

  bool isMailBlocked(int mailId) => _box.get('blockedMails', defaultValue: Settings().blockedMails).indexOf(mailId) >= 0;

  void blockPost(int postId) {
    List<int> blockedPosts = _box.get('blockedPosts', defaultValue: Settings().blockedPosts);
    if (blockedPosts.indexOf(postId) == -1) {
      blockedPosts.add(postId);
    }
    _box.put('blockedPosts', blockedPosts);
  }

  void blockMail(int mailId) {
    List<int> blockedMails = _box.get('blockedMails', defaultValue: Settings().blockedMails);
    if (blockedMails.indexOf(mailId) == -1) {
      blockedMails.add(mailId);
    }
    _box.put('blockedMails', blockedMails);
  }

  void resetBlockedContent() {
    _box.delete('blockedPosts');
    _box.delete('blockedMails');
    _box.delete('blockedUsers');
  }

  bool isUserBlocked(String user) => _box.get('blockedUsers', defaultValue: Settings().blockedUsers).indexOf(user) >= 0;

  void blockUser(String user) {
    List<String> blockedUsers = _box.get('blockedUsers', defaultValue: Settings().blockedUsers);
    if (blockedUsers.indexOf(user) == -1) {
      blockedUsers.add(user);
    }
    _box.put('blockedUsers', blockedUsers);
  }
}
