import 'package:fyx/model/enums/DefaultView.dart';

class Settings {
  bool useCompactMode = false;
  DefaultView defaultView = DefaultView.history;
  List<int> blockedPosts = [];
  List<int> blockedMails = [];
  List<String> blockedUsers = [];
}
