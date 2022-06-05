import 'package:hive/hive.dart';

part 'FirstUnreadEnum.g.dart';

@HiveType(typeId: 10)
enum FirstUnreadEnum {
  @HiveField(11)
  off,
  @HiveField(12)
  button,
  @HiveField(13)
  autoscroll
}
