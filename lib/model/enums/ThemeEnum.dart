import 'package:hive/hive.dart';

part 'ThemeEnum.g.dart';

@HiveType(typeId: 5)
enum ThemeEnum {
  @HiveField(5)
  light,
  @HiveField(6)
  dark,
  @HiveField(7)
  system
}