import 'package:fyx/model/Discussion.dart';

class Bookmark {
  int categoryId = 0;
  String categoryName = '';
  List<Discussion> discussions = [];

  Bookmark.fromJson(Map<String, dynamic> json) {
    this.categoryId = json['category']['id'];
    this.categoryName = json['category']['category_name'];
    this.discussions = (json['bookmarks'] as List).map((discussion) => Discussion.fromJson(discussion)).toList();
  }
}