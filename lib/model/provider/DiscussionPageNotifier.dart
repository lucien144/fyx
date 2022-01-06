import 'package:flutter/cupertino.dart';

class DiscussionPageNotifier extends ChangeNotifier {
  int _deletedPostId = 0;

  int get deletedPostId => _deletedPostId;

  set deletedPostId(int val) {
    _deletedPostId = val;
    notifyListeners();
  }

  resetPostId() {
    _deletedPostId = 0;
    // Do not notify!
  }
}
