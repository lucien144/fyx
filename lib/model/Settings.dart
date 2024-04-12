import 'package:fyx/model/enums/DefaultView.dart';
import 'package:fyx/model/enums/FirstUnreadEnum.dart';
import 'package:fyx/model/enums/LaunchModeEnum.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings {
  bool useCompactMode = false;
  bool useMarkdown = false;
  bool useBulkActions = true;
  bool useAutocorrect = true;
  bool quickRating = true;
  bool useFyxImageCache = false; // Wheter to use internal image case or not. May fix crashes on big images. #413
  // Settings -> what is the default view when app restart?
  DefaultView defaultView = DefaultView.history;
  // Save the last screen view
  DefaultView latestView = DefaultView.history;
  List<int> blockedPosts = [];
  List<int> blockedMails = [];
  List<String> blockedUsers = [];
  List<String> savedSearch = [];
  Map<int, String> nsfwDiscussionList = {};
  ThemeEnum theme = ThemeEnum.system;
  SkinEnum skin = SkinEnum.fyx;
  double fontSize = 16;
  FirstUnreadEnum firstUnread = FirstUnreadEnum.button;
  LaunchModeEnum linksMode = LaunchModeEnum.externalApplication;
  String whatsNew = '';
}
