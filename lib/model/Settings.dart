import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';

class Settings {
  bool useCompactMode = false;
  bool useAutocorrect = true;
  // Settings -> what is the default view when app restart?
  DefaultView defaultView = DefaultView.history;
  // Save the last screen view
  DefaultView latestView = DefaultView.history;
  List<int> blockedPosts = [];
  List<int> blockedMails = [];
  List<String> blockedUsers = [];
  ThemeEnum theme = ThemeEnum.system;
  FirstUnreadEnum firstUnread = FirstUnreadEnum.button;
}
