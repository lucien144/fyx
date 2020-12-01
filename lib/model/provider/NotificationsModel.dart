import 'package:flutter/cupertino.dart';

class NotificationsModel extends ChangeNotifier {
  int _newMails = 0;
  int _newNotices = 0;

  int get newMails => _newMails;
  int get newNotices => _newNotices;

  void setNewMails(int val) {
    _newMails = val ??= 0;
    notifyListeners();
  }

  void setNewNotices(int val) {
    _newNotices = val ??= 0;
    notifyListeners();
  }
}
