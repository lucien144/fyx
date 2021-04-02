import 'package:fyx/model/Bookmark.dart';

class BookmarksAllResponse {
  List<Bookmark> bookmarks = [];

  BookmarksAllResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('bookmarks') && json['bookmarks'] is List) {
      bookmarks = (json['bookmarks'] as List).map((bookmark) => Bookmark.fromJson(bookmark)).toList();
    }
  }
}
