import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/LaunchModeEnum.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings {
  bool useCompactMode = false;
  bool useAutocorrect = true;
  bool quickRating = true;
  // Settings -> what is the default view when app restart?
  DefaultView defaultView = DefaultView.history;
  // Save the last screen view
  DefaultView latestView = DefaultView.history;
  List<int> blockedPosts = [];
  List<int> blockedMails = [];
  List<String> blockedUsers = [];
  ThemeEnum theme = ThemeEnum.system;
  SkinEnum skin = SkinEnum.fyx;
  double fontSize = 16;
  FirstUnreadEnum firstUnread = FirstUnreadEnum.button;
  LaunchModeEnum linksMode = LaunchModeEnum.externalApplication;
}
