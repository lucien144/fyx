enum DefaultView { history, historyUnread, bookmarks, bookmarksUnread }

class Settings {
  bool useCompactMode = false;
  DefaultView defaultView = DefaultView.history;
  List<int> blockedPosts = [];
  List<int> blockedMails = [];
  List<String> blockedUsers = [];
}
