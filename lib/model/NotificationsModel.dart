import 'package:flutter/cupertino.dart';

class NotificationsModel extends ChangeNotifier {
  int _newMails = 0;

  int get newMails => _newMails;

  void setNewMails(int val) {
    _newMails = val ??= 0;
    notifyListeners();
  }
}
