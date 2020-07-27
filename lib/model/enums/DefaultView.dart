import 'package:hive/hive.dart';

part 'DefaultView.g.dart';

@HiveType(typeId: 0)
enum DefaultView {
  @HiveField(0)
  history,
  @HiveField(1)
  historyUnread,
  @HiveField(2)
  bookmarks,
  @HiveField(3)
  bookmarksUnread
}
