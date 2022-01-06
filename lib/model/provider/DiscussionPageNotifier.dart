import 'package:flutter/cupertino.dart';

class DiscussionPageNotifier extends ChangeNotifier {
  List<int> _deletedPostIds = [];

  List<int> get deletedPostIds => _deletedPostIds;

  addPostToDelete(int val) {
    _deletedPostIds.add(val);
    notifyListeners();
  }

  clearPostsToDelete() {
    _deletedPostIds = [];
    // Do not notify!
  }
}
