enum DefaultView { history, historyUnread, bookmarks, bookmarksUnread }

class Settings {
  bool useCompactMode = false;
  DefaultView defaultView = DefaultView.history;
}
