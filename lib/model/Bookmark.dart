import 'package:fyx/model/Discussion.dart';

class Bookmark {
  int categoryId = 0;
  String categoryName = '';
  List<Discussion> bookmarks = [];

  Bookmark.fromJson(Map<String, dynamic> json) {
    this.categoryId = json['category']['id'];
    this.categoryName = json['category']['category_name'];
    this.bookmarks = (json['bookmarks'] as List).map((bookmark) => Discussion.fromJson(bookmark)).toList();
  }
}