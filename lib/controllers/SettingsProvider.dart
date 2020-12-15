import 'package:fyx/model/Settings.dart';
import 'package:fyx/model/enums/DefaultView.dart';
import "package:hive/hive.dart";
import "package:hive_flutter/hive_flutter.dart";

class SettingsProvider {
  static final SettingsProvider _singleton = SettingsProvider._internal();
  Settings _settings;
  Box<dynamic> _box;

  Box<dynamic> get box => _box;

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

  List get blockedMails => _box.get('blockedMails', defaultValue: Settings().blockedMails);

  List get blockedPosts => _box.get('blockedPosts', defaultValue: Settings().blockedPosts);

  List get blockedUsers => _box.get('blockedUsers', defaultValue: Settings().blockedUsers);

  int get photoQuality => _box.get('photoQuality', defaultValue: Settings().photoQuality);
  set photoQuality(int quality) {
    _box.put('photoQuality', quality);
    _settings.photoQuality = quality;
  }

  int get photoWidth => _box.get('photoWidth', defaultValue: Settings().photoWidth);
  set photoWidth(int width) {
    _box.put('photoWidth', width);
    _settings.photoWidth = width;
  }

  factory SettingsProvider() {
    return _singleton;
  }

  SettingsProvider._internal();

  Future<SettingsProvider> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DefaultViewAdapter());
    _box = await Hive.openBox('settings');

    _settings = new Settings();
    _settings.defaultView = _box.get('defaultView', defaultValue: Settings().defaultView);
    _settings.latestView = _box.get('latestView', defaultValue: Settings().latestView);
    _settings.useCompactMode = _box.get('useCompactMode', defaultValue: Settings().useCompactMode);
    _settings.useAutocorrect = _box.get('useAutocorrect', defaultValue: Settings().useAutocorrect);
    _settings.photoQuality = _box.get('photoQuality', defaultValue: Settings().photoQuality);
    _settings.photoWidth = _box.get('photoWidth', defaultValue: Settings().photoWidth);

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
